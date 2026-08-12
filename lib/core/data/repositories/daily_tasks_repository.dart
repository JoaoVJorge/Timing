import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class DailyTasksRepository {
  DailyTasksRepository({required this._dailyTasksDataSource});

  final DailyTasksDataSource _dailyTasksDataSource;

  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() =>
      _dailyTasksDataSource.getTasks();

  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) =>
      _dailyTasksDataSource.saveTasks(tasks);
}
