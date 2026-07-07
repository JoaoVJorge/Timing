import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/daily_tasks_repository.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetDailyTasksUseCase {
  GetDailyTasksUseCase({required this._dailyTasksRepository});

  final DailyTasksRepository _dailyTasksRepository;

  Future<Either<AppError, List<DailyTaskEntity>>> call() =>
      _dailyTasksRepository.getTasks();
}
