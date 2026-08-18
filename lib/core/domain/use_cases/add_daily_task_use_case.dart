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
  }) async {
    final Either<AppError, List<DailyTaskEntity>> getResult =
        await _dailyTasksRepository.getTasks();

    return getResult.fold((error) async => Left(error), (tasks) async {
      final DailyTaskEntity newTask = DailyTaskEntity(
        id: generateEntityId(),
        name: name,
        colorValue: colorValue,
        targetDays: targetDays,
        completedDates: const [],
        sequenceType: sequenceType,
        goalType: sequenceType == DailyTaskSequenceType.intense
            ? DailyTaskGoalType.daily
            : DailyTaskGoalType.total,
      );

      final Either<AppError, void> saveResult = await _dailyTasksRepository
          .saveTasks([...tasks, newTask]);

      return saveResult.fold(Left.new, (_) => Right(newTask));
    });
  }
}
