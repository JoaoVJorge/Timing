import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:help_out/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:help_out/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";

class DailyGoalsController extends GetxController {
  DailyGoalsController({
    required this._appNavigator,
    required this._getDailyTasksUseCase,
    required this._toggleDailyTaskCheckUseCase,
    required this._deleteDailyTaskUseCase,
    required this._lastActivityService,
  });

  final AppNavigator _appNavigator;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final ToggleDailyTaskCheckUseCase _toggleDailyTaskCheckUseCase;
  final DeleteDailyTaskUseCase _deleteDailyTaskUseCase;
  final LastActivityService _lastActivityService;

  final RxList<DailyTaskEntity> tasks = <DailyTaskEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final Either<AppError, List<DailyTaskEntity>> result =
        await _getDailyTasksUseCase();
    result.fold((error) => null, (loadedTasks) => tasks.value = loadedTasks);
  }

  Future<void> onTapAddTask() async {
    final dynamic result = await _appNavigator.toNamed(AppRoutes.createTask);
    final DailyTaskEntity? createdTask = result as DailyTaskEntity?;
    if (createdTask != null) {
      tasks.add(createdTask);
    }
  }

  Future<void> onToggleTask(DailyTaskEntity task) async {
    final Either<AppError, DailyTaskEntity> result =
        await _toggleDailyTaskCheckUseCase(taskId: task.id);

    result.fold((error) => _appNavigator.showErrorSnackBar(), (updatedTask) {
      final int index = tasks.indexWhere((item) => item.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
      if (updatedTask.isCheckedToday) {
        _lastActivityService.record(updatedTask.name);
      }
    });
  }

  Future<void> onDeleteTask(DailyTaskEntity task) async {
    tasks.removeWhere((item) => item.id == task.id);
    await _deleteDailyTaskUseCase(taskId: task.id);
  }
}
