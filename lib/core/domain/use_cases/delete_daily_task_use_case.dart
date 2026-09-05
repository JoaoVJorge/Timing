import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class DeleteDailyTaskUseCase {
  DeleteDailyTaskUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, void>> call({required String taskId}) =>
      _dailyTasksRepository.runSerializedMutation(() async {
        final Either<AppError, List<DailyTaskEntity>> getResult =
            await _dailyTasksRepository.getTasksForMutation();

        return getResult.fold(
          (error) async => Left(error),
          (tasks) => _dailyTasksRepository.saveTasks(
            tasks.where((task) => task.id != taskId).toList(),
          ),
        );
      });
}
