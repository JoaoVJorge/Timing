import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/id_generator.dart";

class AddDailyTaskUseCase {
  AddDailyTaskUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, DailyTaskEntity>> call({
    required String name,
    required int colorValue,
    required int targetDays,
    required DailyTaskSequenceType sequenceType,
    bool reuseMatchingTask = false,
    String? groupId,
    String? groupActivityId,
    String? id,
  }) => _dailyTasksRepository.runSerializedMutation(() async {
    final Either<AppError, List<DailyTaskEntity>> getResult =
        await _dailyTasksRepository.getTasks();

    return getResult.fold((error) async => Left(error), (tasks) async {
      if (reuseMatchingTask) {
        final String normalizedName = name.trim().toLowerCase();
        final int matchIndex = tasks.indexWhere(
          (task) =>
              task.name.trim().toLowerCase() == normalizedName &&
              task.targetDays == targetDays &&
              task.sequenceType == sequenceType &&
              (groupActivityId == null ||
                  task.groupActivityId == groupActivityId ||
                  task.groupId == groupId && task.groupActivityId == null),
        );
        if (matchIndex != -1) {
          final DailyTaskEntity match = tasks[matchIndex];
          // Reusing an existing goal for a group: stamp the group link so it
          // becomes protected from direct deletion like a fresh group goal.
          if (groupId != null &&
              (match.groupId != groupId ||
                  match.groupActivityId != groupActivityId)) {
            final DailyTaskEntity linked = match.copyWith(
              groupId: groupId,
              groupActivityId: groupActivityId,
              updatedAt: DateTime.now().toUtc(),
            );
            final List<DailyTaskEntity> updatedTasks = [...tasks]
              ..[matchIndex] = linked;
            final Either<AppError, void> saveResult =
                await _dailyTasksRepository.saveTasks(updatedTasks);
            return saveResult.fold(Left.new, (_) => Right(linked));
          }
          return Right(match);
        }
      }

      final DailyTaskEntity newTask = DailyTaskEntity(
        id: id ?? generateEntityId(),
        name: name,
        colorValue: colorValue,
        targetDays: targetDays,
        completedDates: const [],
        sequenceType: sequenceType,
        goalType: sequenceType == DailyTaskSequenceType.intense
            ? DailyTaskGoalType.daily
            : DailyTaskGoalType.total,
        updatedAt: DateTime.now().toUtc(),
        groupId: groupId,
        groupActivityId: groupActivityId,
      );

      final Either<AppError, void> saveResult = await _dailyTasksRepository
          .saveTasks([...tasks, newTask]);

      return saveResult.fold(Left.new, (_) => Right(newTask));
    });
  });
}
