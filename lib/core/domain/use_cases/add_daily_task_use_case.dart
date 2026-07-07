import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/daily_tasks_repository.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class AddDailyTaskUseCase {
  AddDailyTaskUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, DailyTaskEntity>> call({
    required String name,
    required int colorValue,
    required int targetDays,
  }) async {
    final Either<AppError, List<DailyTaskEntity>> getResult =
        await _dailyTasksRepository.getTasks();

    return getResult.fold((error) async => Left(error), (tasks) async {
      final DailyTaskEntity newTask = DailyTaskEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        colorValue: colorValue,
        targetDays: targetDays,
        completedDates: const [],
      );

      final Either<AppError, void> saveResult = await _dailyTasksRepository
          .saveTasks([...tasks, newTask]);

      return saveResult.fold(Left.new, (_) => Right(newTask));
    });
  }
}
