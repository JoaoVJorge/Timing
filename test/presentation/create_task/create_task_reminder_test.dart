import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/update_daily_task_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/presentation/create_task/create_task_controller.dart";

class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Navigator extends _Unused implements AppNavigator {
  int errors = 0;

  @override
  void showErrorSnackBar([String? text]) => errors++;
}

class _Achievements extends _Unused implements AchievementUnlockService {
  @override
  Future<void> checkForNewUnlocks() async {}
}

class _Repository extends _Unused implements DailyTasksRepository {
  _Repository(this.tasks);

  List<DailyTaskEntity> tasks;

  @override
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) =>
      mutation();

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasksForMutation() async =>
      Right(tasks);

  @override
  Future<Either<AppError, void>> saveTasks(
    List<DailyTaskEntity> updatedTasks,
  ) async {
    tasks = updatedTasks;
    return const Right(null);
  }
}

const DailyTaskEntity _saved = DailyTaskEntity(
  id: "a",
  name: "Beber água",
  colorValue: 1,
  targetDays: 5,
  completedDates: ["2026-10-06"],
  reminderMinutes: 7 * 60,
);

void main() {
  late _Repository repository;
  late _Navigator navigator;
  bool permissionGranted = true;

  CreateTaskController build({
    DailyTaskEntity? editing,
    bool hasNotifications = true,
  }) => Get.put(
    CreateTaskController(
      addDailyTaskUseCase: AddDailyTaskUseCase(
        dailyTasksRepository: repository,
      ),
      updateDailyTaskUseCase: UpdateDailyTaskUseCase(
        dailyTasksRepository: repository,
      ),
      appNavigator: navigator,
      achievementUnlockService: _Achievements(),
      ensureNotificationsEnabled: hasNotifications
          ? () async => permissionGranted
          : null,
      editingTask: editing,
    ),
  );

  setUp(() {
    permissionGranted = true;
    navigator = _Navigator();
    repository = _Repository([_saved]);
  });

  tearDown(Get.reset);

  test("a new goal has no reminder unless one is turned on", () async {
    final CreateTaskController controller = build();
    controller.nameController.text = "Ler";

    await controller.onSubmit();

    expect(repository.tasks.last.reminderMinutes, isNull);
  });

  test("picking a time turns the reminder on and saves it", () async {
    final CreateTaskController controller = build();
    controller.nameController.text = "Ler";

    await controller.onPickReminderTime(21 * 60 + 30);
    await controller.onSubmit();

    expect(controller.reminderEnabled.value, true);
    expect(repository.tasks.last.reminderMinutes, 21 * 60 + 30);
  });

  test("the reminder stays off when notifications are not allowed", () async {
    permissionGranted = false;
    final CreateTaskController controller = build();
    controller.nameController.text = "Ler";

    await controller.onToggleReminder(true);
    await controller.onSubmit();

    expect(controller.reminderEnabled.value, false);
    expect(navigator.errors, 1);
    expect(repository.tasks.last.reminderMinutes, isNull);
  });

  test("a platform without notifications offers no reminder", () async {
    final CreateTaskController controller = build(hasNotifications: false);

    await controller.onToggleReminder(true);

    expect(controller.supportsReminders, false);
    expect(controller.reminderEnabled.value, false);
    expect(navigator.errors, 0);
  });

  test("editing a goal shows its reminder and keeps it", () async {
    final CreateTaskController controller = build(editing: _saved);

    expect(controller.reminderEnabled.value, true);
    expect(controller.reminderMinutes.value, 7 * 60);

    await controller.onSubmit();

    expect(repository.tasks.single.reminderMinutes, 7 * 60);
  });

  test("turning the reminder off while editing removes it", () async {
    final CreateTaskController controller = build(editing: _saved);

    await controller.onToggleReminder(false);
    await controller.onSubmit();

    expect(repository.tasks.single.reminderMinutes, isNull);
  });
}
