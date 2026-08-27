import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class ToggleDailyTaskCheckUseCase {
  ToggleDailyTaskCheckUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, DailyTaskEntity>> call({
    required String taskId,
    DateTime? date,
    String? resolvedMissedDate,
    bool toggleDate = true,
  }) => _dailyTasksRepository.runSerializedMutation(() async {
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
      final List<String> completedDates = toggleDate
          ? task.completedDatesAfterToggle(date ?? DateTime.now())
          : task.completedDates;

      final DailyTaskEntity updatedTask = task.copyWith(
        completedDates: completedDates,
        lastResolvedMissedDate: resolvedMissedDate,
        updatedAt: DateTime.now().toUtc(),
      );
      final List<DailyTaskEntity> updatedTasks = [...tasks]
        ..[index] = updatedTask;

      final Either<AppError, void> saveResult = await _dailyTasksRepository
          .saveTasks(updatedTasks);

      return saveResult.fold(Left.new, (_) => Right(updatedTask));
    });
  });
}
