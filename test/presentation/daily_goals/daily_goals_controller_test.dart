import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/shared/widgets/delete_confirmation_dialog.dart";

class _ControllableDailyTasksDataSource implements DailyTasksDataSource {
  _ControllableDailyTasksDataSource(this.tasks, {this.failSaves = false});

  List<DailyTaskEntity> tasks;
  final bool failSaves;
  final Completer<void> firstSaveStarted = Completer<void>();
  final Completer<void> releaseFirstSave = Completer<void>();
  int saveCalls = 0;

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async =>
      Right(List.of(tasks));

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
        GenericAppError(error: "save failed", stackTrace: StackTrace.current),
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

  @override
  void showErrorSnackBar([String? text]) {
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
  _ControllableDailyTasksDataSource dataSource,
  _RecordingNavigator navigator, {
  DeleteConfirmationCallback? confirmDelete,
}) {
  final DailyTasksRepository repository = DailyTasksRepository(
    dailyTasksDataSource: dataSource,
  );
  return DailyGoalsController(
    appNavigator: navigator,
    getDailyTasksUseCase: GetDailyTasksUseCase(
      dailyTasksRepository: repository,
    ),
    toggleDailyTaskCheckUseCase: ToggleDailyTaskCheckUseCase(
      dailyTasksRepository: repository,
    ),
    deleteDailyTaskUseCase: DeleteDailyTaskUseCase(
      dailyTasksRepository: repository,
    ),
    lastActivityService: _NoopLastActivityService(),
    achievementUnlockService: _NoopAchievementUnlockService(),
    activityChangeBus: ActivityChangeBus(),
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
      final _ControllableDailyTasksDataSource dataSource =
          _ControllableDailyTasksDataSource(initial);
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
    final _ControllableDailyTasksDataSource dataSource =
        _ControllableDailyTasksDataSource([task], failSaves: true);
    final _RecordingNavigator navigator = _RecordingNavigator();
    final DailyGoalsController controller = _controller(dataSource, navigator);
    controller.tasks.value = [task];

    await controller.onToggleTask(task);

    expect(controller.tasks.single.isCheckedToday, isFalse);
    expect(navigator.errorCount, 1);
  });

  test("a second toggle for the same task is ignored while saving", () async {
    final DailyTaskEntity task = _task("one");
    final _ControllableDailyTasksDataSource dataSource =
        _ControllableDailyTasksDataSource([task]);
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

  test("failed optimistic delete restores the previous task list", () async {
    final DailyTaskEntity firstTask = _task("one");
    final DailyTaskEntity secondTask = _task("two");
    final _ControllableDailyTasksDataSource dataSource =
        _ControllableDailyTasksDataSource([
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
