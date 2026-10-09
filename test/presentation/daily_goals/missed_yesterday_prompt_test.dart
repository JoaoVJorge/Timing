import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/presentation/daily_goals/widgets/missed_yesterday_multi_dialog.dart";

class _InMemoryDailyTasksRepository implements DailyTasksRepository {
  _InMemoryDailyTasksRepository(this.tasks);

  List<DailyTaskEntity> tasks;

  Future<void> _mutationTail = Future<void>.value();

  /// The repository's own queue, so the mutations under test are serialized
  /// exactly as they are in the app.
  @override
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) {
    final Future<T> scheduled = _mutationTail.then((_) => mutation());
    _mutationTail = scheduled.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return scheduled;
  }

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() =>
      runSerializedMutation(() async => Right(List.of(tasks)));

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getLocalTasks() async =>
      Right(List.of(tasks));

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasksForMutation() async =>
      Right(List.of(tasks));

  @override
  Future<Either<AppError, void>> saveTasks(
    List<DailyTaskEntity> updatedTasks,
  ) async {
    tasks = List.of(updatedTasks);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records every dialog the controller opens and leaves it pending until the
/// test answers it, the way a user would.
class _DialogRecordingNavigator implements AppNavigator {
  final List<Widget> dialogs = <Widget>[];
  final List<Completer<Object?>> _answers = <Completer<Object?>>[];

  @override
  Future<T?> dialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    bool useSafeArea = true,
  }) async {
    dialogs.add(child);
    final Completer<Object?> answer = Completer<Object?>();
    _answers.add(answer);
    return await answer.future as T?;
  }

  void answer(int index, Object? result) => _answers[index].complete(result);

  @override
  void showErrorSnackBar([String? text]) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopLastActivityService implements LastActivityService {
  @override
  Future<void> record(String label, {String? subjectId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopAchievementUnlockService implements AchievementUnlockService {
  @override
  Future<void> checkForNewUnlocks() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DailyGoalsController _controller(
  _InMemoryDailyTasksRepository dataSource,
  _DialogRecordingNavigator navigator,
) {
  final DailyTasksRepository repository = dataSource;
  return DailyGoalsController(
    appNavigator: navigator,
    dailyTasksRepository: repository,
    toggleDailyTaskCheckUseCase: ToggleDailyTaskCheckUseCase(
      dailyTasksRepository: repository,
    ),
    deleteDailyTaskUseCase: DeleteDailyTaskUseCase(
      dailyTasksRepository: repository,
    ),
    lastActivityService: _NoopLastActivityService(),
    achievementUnlockService: _NoopAchievementUnlockService(),
    activityChangeBus: ActivityChangeBus(),
  );
}

String _daysAgo(int days) =>
    DailyTaskEntity.dateKey(DateTime.now().subtract(Duration(days: days)));

DailyTaskEntity _intenseGoal(String id, {List<String>? completedDates}) =>
    DailyTaskEntity(
      id: id,
      name: id,
      colorValue: 0xFF3366FF,
      targetDays: 7,
      completedDates: completedDates ?? [_daysAgo(2)],
      sequenceType: DailyTaskSequenceType.intense,
    );

Future<void> _settle(WidgetTester tester) async {
  // The prompt waits for a frame, which the page's Obx would schedule in the
  // app. Draw a few so the prompt runs and its futures complete.
  for (int i = 0; i < 5; i++) {
    tester.binding.scheduleFrame();
    await tester.pump();
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) =>
      tester.pumpWidget(const GetMaterialApp(home: SizedBox()));

  testWidgets("two goals missed yesterday are asked about in one checklist", (
    tester,
  ) async {
    await pumpApp(tester);
    final _InMemoryDailyTasksRepository dataSource =
        _InMemoryDailyTasksRepository([
          _intenseGoal("read"),
          _intenseGoal("train"),
        ]);
    final _DialogRecordingNavigator navigator = _DialogRecordingNavigator();
    final DailyGoalsController controller = _controller(dataSource, navigator);

    await tester.runAsync(controller.loadTasks);
    await _settle(tester);

    expect(navigator.dialogs, hasLength(1));
    final Widget dialog = navigator.dialogs.single;
    expect(dialog, isA<MissedYesterdayMultiDialog>());
    expect(
      (dialog as MissedYesterdayMultiDialog).tasks.map((task) => task.id),
      ["read", "train"],
    );

    navigator.answer(0, <String>{"read", "train"});
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await _settle(tester);

    for (final DailyTaskEntity saved in dataSource.tasks) {
      expect(saved.completedDates, contains(_daysAgo(1)));
      expect(saved.lastResolvedMissedDate, _daysAgo(1));
    }
    expect(navigator.dialogs, hasLength(1));
  });

  testWidgets("a reload while the question is open does not ask twice", (
    tester,
  ) async {
    await pumpApp(tester);
    final _InMemoryDailyTasksRepository dataSource =
        _InMemoryDailyTasksRepository([
          _intenseGoal("read"),
          _intenseGoal("train"),
        ]);
    final _DialogRecordingNavigator navigator = _DialogRecordingNavigator();
    final DailyGoalsController controller = _controller(dataSource, navigator);

    await tester.runAsync(controller.loadTasks);
    await _settle(tester);
    // E.g. the groups tab refreshing the goals behind the open dialog.
    await tester.runAsync(controller.loadTasks);
    await _settle(tester);

    expect(navigator.dialogs, hasLength(1));

    navigator.answer(0, <String>{"read"});
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await _settle(tester);

    final Map<String, DailyTaskEntity> saved = {
      for (final DailyTaskEntity task in dataSource.tasks) task.id: task,
    };
    expect(saved["read"]!.completedDates, contains(_daysAgo(1)));
    expect(saved["train"]!.completedDates, isNot(contains(_daysAgo(1))));
    expect(navigator.dialogs, hasLength(1));
  });
}
