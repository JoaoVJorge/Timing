import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/daily_tasks_repository.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class DeleteDailyTaskUseCase {
  DeleteDailyTaskUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, void>> call({required String taskId}) async {
    final Either<AppError, List<DailyTaskEntity>> getResult =
        await _dailyTasksRepository.getTasks();

    return getResult.fold(
      (error) async => Left(error),
      (tasks) => _dailyTasksRepository.saveTasks(
        tasks.where((task) => task.id != taskId).toList(),
      ),
    );
  }
}
