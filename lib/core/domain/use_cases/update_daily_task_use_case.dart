import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/daily_tasks_repository.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class UpdateDailyTaskUseCase {
  UpdateDailyTaskUseCase({required this.dailyTasksRepository});

  final DailyTasksRepository dailyTasksRepository;

  Future<Either<AppError, DailyTaskEntity>> call({
    required DailyTaskEntity task,
    required String name,
    required int colorValue,
    required int targetDays,
    required DailyTaskGoalType goalType,
  }) async {
    final Either<AppError, List<DailyTaskEntity>> getResult =
        await dailyTasksRepository.getTasks();

    return getResult.fold((error) async => Left(error), (tasks) async {
      final int index = tasks.indexWhere((item) => item.id == task.id);
      if (index == -1) {
        return Left(
          GenericAppError(
            error: "Task not found: ${task.id}",
            stackTrace: StackTrace.current,
          ),
        );
      }

      final DailyTaskEntity updatedTask = task.copyWith(
        name: name,
        colorValue: colorValue,
        targetDays: targetDays,
        goalType: goalType,
      );
      final List<DailyTaskEntity> updatedTasks = [...tasks]
        ..[index] = updatedTask;

      final Either<AppError, void> saveResult = await dailyTasksRepository
          .saveTasks(updatedTasks);

      return saveResult.fold(Left.new, (_) => Right(updatedTask));
    });
  }
}
