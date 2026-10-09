import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
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
import "package:timing/shared/widgets/delete_confirmation_dialog.dart";

class _ControllableDailyTasksRepository implements DailyTasksRepository {
  _ControllableDailyTasksRepository(this.tasks, {this.failSaves = false});

  List<DailyTaskEntity> tasks;
  final bool failSaves;
  final Completer<void> firstSaveStarted = Completer<void>();
  final Completer<void> releaseFirstSave = Completer<void>();
  int saveCalls = 0;

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
    saveCalls++;
    if (saveCalls == 1 && !failSaves) {
      firstSaveStarted.complete();
      await releaseFirstSave.future;
    }
    if (failSaves) {
      return Left(
        UnexpectedError(cause: "save failed", stackTrace: StackTrace.current),
      );
    }
    tasks = List.of(updatedTasks);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingNavigator implements AppNavigator {
  int errorCount = 0;
  int dialogCount = 0;
  final List<String> successMessages = <String>[];

  @override
  void showSuccessSnackBar(String text) {
    successMessages.add(text);
  }

  @override
  Future<T?> dialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    bool useSafeArea = true,
  }) async {
    dialogCount++;
    return null;
  }

  @override
  void showErrorSnackBar([String? text]) {
    errorCount++;
  }

  @override
  void showError(AppError error) {
    errorCount++;
  }

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
  _ControllableDailyTasksRepository dataSource,
  _RecordingNavigator navigator, {
  DeleteConfirmationCallback? confirmDelete,
  ActivityChangeBus? activityChangeBus,
}) {
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
    activityChangeBus: activityChangeBus ?? ActivityChangeBus(),
    confirmDelete:
        confirmDelete ??
        ({required String itemName, String? itemTypeName}) async => false,
  );
}

DailyTaskEntity _task(String id) => DailyTaskEntity(
  id: id,
  name: id,
  colorValue: 1,
  targetDays: 7,
  completedDates: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    "different optimistic toggles persist without overwriting each other",
    () async {
      final List<DailyTaskEntity> initial = [_task("one"), _task("two")];
      final _ControllableDailyTasksRepository dataSource =
          _ControllableDailyTasksRepository(initial);
      final DailyGoalsController controller = _controller(
        dataSource,
        _RecordingNavigator(),
      );
      controller.tasks.value = List.of(initial);

      final Future<void> first = controller.onToggleTask(initial[0]);
      await dataSource.firstSaveStarted.future;
      final Future<void> second = controller.onToggleTask(initial[1]);

      expect(controller.tasks.every((task) => task.isCheckedToday), isTrue);

      dataSource.releaseFirstSave.complete();
      await Future.wait([first, second]);

      expect(dataSource.tasks.every((task) => task.isCheckedToday), isTrue);
      expect(dataSource.saveCalls, 2);
    },
  );

  test("failed optimistic toggle restores the original task", () async {
    final DailyTaskEntity task = _task("one");
    final _ControllableDailyTasksRepository dataSource =
        _ControllableDailyTasksRepository([task], failSaves: true);
    final _RecordingNavigator navigator = _RecordingNavigator();
    final DailyGoalsController controller = _controller(dataSource, navigator);
    controller.tasks.value = [task];

    await controller.onToggleTask(task);

    expect(controller.tasks.single.isCheckedToday, isFalse);
    expect(navigator.errorCount, 1);
  });

  test("a second toggle for the same task is ignored while saving", () async {
    final DailyTaskEntity task = _task("one");
    final _ControllableDailyTasksRepository dataSource =
        _ControllableDailyTasksRepository([task]);
    final DailyGoalsController controller = _controller(
      dataSource,
      _RecordingNavigator(),
    );
    controller.tasks.value = [task];

    final Future<void> first = controller.onToggleTask(task);
    await dataSource.firstSaveStarted.future;
    await controller.onToggleTask(task);

    expect(dataSource.saveCalls, 1);
    expect(controller.tasks.single.isCheckedToday, isTrue);

    dataSource.releaseFirstSave.complete();
    await first;
    expect(dataSource.saveCalls, 1);
  });

  test("marking a group goal done is immediate, with no dialog", () async {
    const DailyTaskEntity groupGoal = DailyTaskEntity(
      id: "grp_ga1",
      name: "Meta do grupo",
      colorValue: 1,
      targetDays: 7,
      completedDates: [],
      groupId: "g1",
      groupActivityId: "ga1",
    );
    final _ControllableDailyTasksRepository dataSource =
        _ControllableDailyTasksRepository([groupGoal]);
    final _RecordingNavigator navigator = _RecordingNavigator();
    final DailyGoalsController controller = _controller(dataSource, navigator);
    controller.tasks.value = [groupGoal];

    final Future<void> check = controller.onToggleTask(groupGoal);
    await dataSource.firstSaveStarted.future;
    // Checked on screen before the save even finishes: nothing was asked.
    expect(controller.tasks.single.isCheckedToday, isTrue);
    dataSource.releaseFirstSave.complete();
    await check;

    expect(dataSource.tasks.single.isCheckedToday, isTrue);

    await controller.onToggleTask(controller.tasks.single);

    expect(dataSource.tasks.single.isCheckedToday, isFalse);
    expect(navigator.dialogCount, 0);
  });

  test("failed optimistic delete restores the previous task list", () async {
    final DailyTaskEntity firstTask = _task("one");
    final DailyTaskEntity secondTask = _task("two");
    final _ControllableDailyTasksRepository dataSource =
        _ControllableDailyTasksRepository([
          firstTask,
          secondTask,
        ], failSaves: true);
    final _RecordingNavigator navigator = _RecordingNavigator();
    final DailyGoalsController controller = _controller(
      dataSource,
      navigator,
      confirmDelete: ({required String itemName, String? itemTypeName}) async =>
          true,
    );
    controller.tasks.value = [firstTask, secondTask];

    await controller.onDeleteTask(firstTask);

    expect(controller.tasks, [firstTask, secondTask]);
    expect(navigator.errorCount, 1);
    expect(dataSource.saveCalls, 1);
  });
}
