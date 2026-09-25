import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

/// Wipes the days marked on a goal, keeping the goal itself. A group goal is
/// ranked from those days, so this also takes the user's share out of the group.
class ClearDailyTaskDataUseCase {
  ClearDailyTaskDataUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, DailyTaskEntity>> call({required String taskId}) =>
      _dailyTasksRepository.runSerializedMutation(() async {
        final Either<AppError, List<DailyTaskEntity>> getResult =
            await _dailyTasksRepository.getTasksForMutation();

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

          // The newer updatedAt is what makes this win over a stale remote
          // copy that still lists the days.
          final DailyTaskEntity clearedTask = tasks[index].copyWith(
            completedDates: const [],
            updatedAt: DateTime.now().toUtc(),
          );
          final List<DailyTaskEntity> updatedTasks = [...tasks]
            ..[index] = clearedTask;

          final Either<AppError, void> saveResult = await _dailyTasksRepository
              .saveTasks(updatedTasks);
          return saveResult.fold(Left.new, (_) => Right(clearedTask));
        });
      });
}
