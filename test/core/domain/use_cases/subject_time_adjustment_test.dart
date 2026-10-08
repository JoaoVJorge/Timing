import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_subject_time_use_case.dart";
import "package:timing/core/domain/use_cases/remove_subject_time_use_case.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";

import "../../../support/supabase_test_harness.dart";

class _FakeSubjectsRepository implements SubjectsRepository {
  _FakeSubjectsRepository(this.subjects);

  List<SubjectEntity> subjects;
  int saveCalls = 0;

  @override
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) =>
      mutation();

  @override
  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async =>
      Right(List.of(subjects));

  @override
  Future<Either<AppError, void>> saveSubjects(
    List<SubjectEntity> updated,
  ) async {
    saveCalls++;
    subjects = List.of(updated);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeActivityRepository implements ActivityRepository {
  /// "subject:seconds" for every session logged.
  final List<String> logged = <String>[];

  /// "subject:seconds" for every removal asked of the backend.
  final List<String> removals = <String>[];
  Either<AppError, void> removalResult = const Right(null);

  @override
  Future<Either<AppError, void>> logActivity({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {
    logged.add("$subjectId:$seconds");
    return const Right(null);
  }

  @override
  Future<Either<AppError, void>> removeSubjectSeconds({
    required String subjectId,
    required int seconds,
  }) async {
    removals.add("$subjectId:$seconds");
    return removalResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SubjectEntity _subject(String id, {int seconds = 0}) => SubjectEntity(
  id: id,
  name: "Atividade $id",
  category: TimeCategoryType.studying,
  colorValue: 1,
  totalSeconds: seconds,
  goalSeconds: 1800,
  currentPages: 5,
  goalPages: 50,
  notes: "",
  iconName: "book",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
);

class _Rig {
  _Rig() {
    final MemoryStorage storage = MemoryStorage();
    activityHistory = ActivityHistoryService(localStorageService: storage);
    subjectHistory = SubjectDailyHistoryService(localStorageService: storage);
    dailyProgress = DailyProgressService(localStorageService: storage);
    add = AddSubjectTimeUseCase(
      subjectsRepository: subjects,
      activityRepository: activity,
      activityHistoryService: activityHistory,
      subjectDailyHistoryService: subjectHistory,
      dailyProgressService: dailyProgress,
      activityChangeBus: bus,
    );
    remove = RemoveSubjectTimeUseCase(
      subjectsRepository: subjects,
      activityRepository: activity,
      activityHistoryService: activityHistory,
      subjectDailyHistoryService: subjectHistory,
      dailyProgressService: dailyProgress,
    );
  }

  final _FakeSubjectsRepository subjects = _FakeSubjectsRepository([
    _subject("a", seconds: 3600),
    _subject("b", seconds: 1200),
  ]);
  final _FakeActivityRepository activity = _FakeActivityRepository();
  final ActivityChangeBus bus = ActivityChangeBus();
  late final ActivityHistoryService activityHistory;
  late final SubjectDailyHistoryService subjectHistory;
  late final DailyProgressService dailyProgress;
  late final AddSubjectTimeUseCase add;
  late final RemoveSubjectTimeUseCase remove;

  SubjectEntity subject(String id) =>
      subjects.subjects.firstWhere((subject) => subject.id == id);

  int trailSeconds(String id) => activityHistory.all
      .where((entry) => entry.subjectId == id)
      .fold(0, (sum, entry) => sum + entry.seconds);
}

void main() {
  late _Rig rig;
  setUp(() => rig = _Rig());

  group("adding time by hand", () {
    test("counts on the total, on today and as a logged session", () async {
      final result = await rig.add(subjectId: "a", seconds: 1800);

      expect(result.getOrElse(() => _subject("x")).totalSeconds, 5400);
      expect(rig.subject("a").totalSeconds, 5400);
      expect(rig.subjectHistory.todayForSubject("a").focusSeconds, 1800);
      expect(rig.dailyProgress.today.value.focusSeconds, 1800);
      expect(rig.trailSeconds("a"), 1800);
      expect(rig.activity.logged, ["a:1800"]);
    });

    test("leaves every other activity alone", () async {
      await rig.add(subjectId: "a", seconds: 600);

      expect(rig.subject("b").totalSeconds, 1200);
      expect(rig.subjectHistory.todayForSubject("b").focusSeconds, 0);
    });

    test("tells the groups once the session is on the backend", () async {
      int notifications = 0;
      final subscription = rig.bus.stream.listen((_) => notifications++);
      addTearDown(subscription.cancel);

      await rig.add(subjectId: "a", seconds: 600);
      await pumpEventQueue();

      expect(notifications, 1);
    });

    test("never logs more than one session can hold", () async {
      await rig.add(subjectId: "a", seconds: 200000);

      expect(rig.activity.logged, ["a:86400"]);
      expect(rig.subject("a").totalSeconds, 3600 + 86400);
    });

    test("an unknown activity is an error and changes nothing", () async {
      final result = await rig.add(subjectId: "gone", seconds: 600);

      expect(result.isLeft(), true);
      expect(rig.subjects.saveCalls, 0);
      expect(rig.activity.logged, isEmpty);
      expect(rig.dailyProgress.today.value.focusSeconds, 0);
    });
  });

  group("removing time by hand", () {
    test("comes off the total, off today and off the backend", () async {
      await rig.add(subjectId: "a", seconds: 1800);

      final result = await rig.remove(subjectId: "a", seconds: 600);

      expect(result.getOrElse(() => _subject("x")).totalSeconds, 4800);
      expect(rig.subject("a").totalSeconds, 4800);
      expect(rig.subjectHistory.todayForSubject("a").focusSeconds, 1200);
      expect(rig.dailyProgress.today.value.focusSeconds, 1200);
      expect(rig.trailSeconds("a"), 1200);
      expect(rig.activity.removals, ["a:600"]);
    });

    test("never takes an activity below zero", () async {
      final result = await rig.remove(subjectId: "b", seconds: 99999);

      expect(result.getOrElse(() => _subject("x")).totalSeconds, 0);
      expect(rig.activity.removals, ["b:1200"]);
    });

    test("time from before the daily trail only leaves the total", () async {
      await rig.add(subjectId: "a", seconds: 300);

      await rig.remove(subjectId: "a", seconds: 900);

      expect(rig.subject("a").totalSeconds, 3000);
      expect(rig.subjectHistory.todayForSubject("a").focusSeconds, 0);
      expect(rig.dailyProgress.today.value.focusSeconds, 0);
    });

    test("leaves other activities' share of today alone", () async {
      await rig.add(subjectId: "a", seconds: 600);
      await rig.add(subjectId: "b", seconds: 400);

      await rig.remove(subjectId: "a", seconds: 600);

      expect(rig.subjectHistory.todayForSubject("b").focusSeconds, 400);
      expect(rig.dailyProgress.today.value.focusSeconds, 400);
      expect(rig.subject("b").totalSeconds, 1600);
    });

    test("an activity with no time is left as it is", () async {
      rig.subjects.subjects = [_subject("a")];

      final result = await rig.remove(subjectId: "a", seconds: 600);

      expect(result.isRight(), true);
      expect(rig.subjects.saveCalls, 0);
      expect(rig.activity.removals, isEmpty);
    });

    test("nothing changes when the request cannot be recorded", () async {
      await rig.add(subjectId: "a", seconds: 600);
      rig.activity.removalResult = Left(
        GenericAppError(error: "storage", stackTrace: StackTrace.current),
      );

      final result = await rig.remove(subjectId: "a", seconds: 300);

      expect(result.isLeft(), true);
      expect(rig.subject("a").totalSeconds, 4200);
      expect(rig.subjectHistory.todayForSubject("a").focusSeconds, 600);
    });
  });
}
