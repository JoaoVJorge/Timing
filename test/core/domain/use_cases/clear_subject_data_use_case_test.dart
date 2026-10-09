import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/clear_subject_data_use_case.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";

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
  final List<String> cleared = <String>[];
  Either<AppError, void> result = const Right(null);

  @override
  Future<Either<AppError, void>> clearSubjectEntries(String subjectId) async {
    cleared.add(subjectId);
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SubjectEntity _subject(String id, {int seconds = 0, int pages = 0}) =>
    SubjectEntity(
      id: id,
      name: "Atividade $id",
      category: TimeCategoryType.studying,
      colorValue: 1,
      totalSeconds: seconds,
      goalSeconds: 1800,
      currentPages: pages,
      goalPages: 50,
      notes: "minhas notas",
      iconName: "book",
      restMinutes: 5,
      focusSessionCount: 3,
      wallpaperIndex: 2,
      groupId: "g1",
      groupActivityId: "ga1",
    );

class _Rig {
  _Rig() {
    final MemoryStorage storage = MemoryStorage();
    activityHistory = ActivityHistoryService(localStorageService: storage);
    subjectHistory = SubjectDailyHistoryService(localStorageService: storage);
    dailyProgress = DailyProgressService(localStorageService: storage);
    lastActivity = LastActivityService(localStorageService: storage);
    useCase = ClearSubjectDataUseCase(
      subjectsRepository: subjects,
      activityRepository: activity,
      activityHistoryService: activityHistory,
      subjectDailyHistoryService: subjectHistory,
      dailyProgressService: dailyProgress,
      lastActivityService: lastActivity,
    );
  }

  final _FakeSubjectsRepository subjects = _FakeSubjectsRepository([
    _subject("a", seconds: 3600, pages: 12),
    _subject("b", seconds: 1200, pages: 3),
  ]);
  final _FakeActivityRepository activity = _FakeActivityRepository();
  late final ActivityHistoryService activityHistory;
  late final SubjectDailyHistoryService subjectHistory;
  late final DailyProgressService dailyProgress;
  late final LastActivityService lastActivity;
  late final ClearSubjectDataUseCase useCase;

  /// What "a" and "b" did today, in every place it is recorded.
  Future<void> seedToday() async {
    for (final (String id, int seconds) in [("a", 600), ("b", 300)]) {
      await activityHistory.record(
        category: TimeCategoryType.studying,
        subjectId: id,
        subjectName: id,
        seconds: seconds,
      );
      await subjectHistory.addFocusSeconds(id, seconds);
      await dailyProgress.addFocusSeconds(seconds);
      await subjectHistory.registerSession(id);
      await dailyProgress.registerSession();
    }
  }
}

void main() {
  test("zeroes the time and pages but keeps the activity as it was", () async {
    final _Rig rig = _Rig();

    final Either<AppError, SubjectEntity> result = await rig.useCase(
      subjectId: "a",
    );

    final SubjectEntity cleared = result.getOrElse(() => throw StateError("x"));
    expect(cleared.totalSeconds, 0);
    expect(cleared.currentPages, 0);
    final SubjectEntity saved = rig.subjects.subjects.firstWhere(
      (subject) => subject.id == "a",
    );
    expect(saved, cleared);
    // Everything that is not progress stays.
    expect(saved.name, "Atividade a");
    expect(saved.goalSeconds, 1800);
    expect(saved.goalPages, 50);
    expect(saved.notes, "minhas notas");
    expect(saved.focusSessionCount, 3);
    expect(saved.groupId, "g1");
    expect(saved.groupActivityId, "ga1");
  });

  test("leaves the other activities alone", () async {
    final _Rig rig = _Rig();

    await rig.useCase(subjectId: "a");

    final SubjectEntity other = rig.subjects.subjects.firstWhere(
      (subject) => subject.id == "b",
    );
    expect(other.totalSeconds, 1200);
    expect(other.currentPages, 3);
  });

  test(
    "asks for that activity's sessions to be deleted on the backend",
    () async {
      final _Rig rig = _Rig();

      await rig.useCase(subjectId: "a");

      expect(rig.activity.cleared, ["a"]);
    },
  );

  test("removes its own history and its share of the daily totals", () async {
    final _Rig rig = _Rig();
    await rig.seedToday();
    expect(rig.dailyProgress.today.value.focusSeconds, 900);

    await rig.useCase(subjectId: "a");

    expect(rig.activityHistory.all.map((entry) => entry.subjectId), ["b"]);
    expect(rig.subjectHistory.todayForSubject("a").isEmpty, isTrue);
    expect(rig.subjectHistory.todayForSubject("b").focusSeconds, 300);
    // What "b" did today is all that is left of the day.
    expect(rig.dailyProgress.today.value.focusSeconds, 300);
  });

  test("takes its sessions out of the progress counters", () async {
    final _Rig rig = _Rig();
    await rig.seedToday();
    expect(rig.dailyProgress.today.value.sessions, 2);

    await rig.useCase(subjectId: "a");

    expect(rig.dailyProgress.today.value.sessions, 1);
  });

  test("forgets the last activity only when it was this one", () async {
    final _Rig rig = _Rig();
    await rig.lastActivity.record("Atividade b", subjectId: "b");

    await rig.useCase(subjectId: "a");
    expect(rig.lastActivity.lastActivity.value?.subjectId, "b");

    await rig.useCase(subjectId: "b");
    expect(rig.lastActivity.lastActivity.value, isNull);
  });

  test("changes nothing when the sessions cannot be deleted", () async {
    final _Rig rig = _Rig();
    await rig.seedToday();
    rig.activity.result = Left(
      UnexpectedError(cause: "refused", stackTrace: StackTrace.current),
    );

    final Either<AppError, SubjectEntity> result = await rig.useCase(
      subjectId: "a",
    );

    expect(result.isLeft(), isTrue);
    expect(rig.subjects.saveCalls, 0);
    expect(rig.subjects.subjects.first.totalSeconds, 3600);
    expect(rig.activityHistory.all, hasLength(2));
    expect(rig.dailyProgress.today.value.focusSeconds, 900);
  });

  test(
    "an activity that does not exist is an error and touches no history",
    () async {
      final _Rig rig = _Rig();
      await rig.seedToday();

      final Either<AppError, SubjectEntity> result = await rig.useCase(
        subjectId: "ghost",
      );

      expect(result.isLeft(), isTrue);
      expect(rig.activityHistory.all, hasLength(2));
      expect(rig.dailyProgress.today.value.focusSeconds, 900);
    },
  );
}
