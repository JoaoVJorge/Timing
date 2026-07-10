import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/daily_tasks_repository.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class ToggleDailyTaskCheckUseCase {
  ToggleDailyTaskCheckUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, DailyTaskEntity>> call({
    required String taskId,
  }) async {
    final Either<AppError, List<DailyTaskEntity>> getResult =
        await _dailyTasksRepository.getTasks();

    return getResult.fold((error) async => Left(error), (tasks) async {
      final int index = tasks.indexWhere((task) => task.id == taskId);
      if (index == -1) {
        return Left(
          GenericAppError(
            error: "Task not found: $taskId",
            stackTrace: StackTrace.current,
          ),
        );
      }

      final DailyTaskEntity task = tasks[index];
      final String today = DailyTaskEntity.dateKey(DateTime.now());
      final List<String> completedDates = task.completedDates.contains(today)
          ? task.completedDates.where((date) => date != today).toList()
          : [...task.completedDates, today];

      final DailyTaskEntity updatedTask = task.copyWith(
        completedDates: completedDates,
      );
      final List<DailyTaskEntity> updatedTasks = [...tasks]
        ..[index] = updatedTask;

      final Either<AppError, void> saveResult = await _dailyTasksRepository
          .saveTasks(updatedTasks);

      return saveResult.fold(Left.new, (_) => Right(updatedTask));
    });
  }
}
