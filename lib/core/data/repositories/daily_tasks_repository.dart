import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class DailyTasksRepository {
  DailyTasksRepository({required this._dailyTasksDataSource});

  final DailyTasksDataSource _dailyTasksDataSource;
  Future<void> _mutationTail = Future<void>.value();

  /// Serializes complete read-modify-write operations so two UI actions cannot
  /// persist competing snapshots of the daily-goals collection.
  ///
  /// Mutations passed here must not call another serialized mutation on this
  /// repository: a nested call would wait for its own outer operation.
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) {
    final Future<T> scheduled = _mutationTail.then((_) => mutation());
    _mutationTail = scheduled.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return scheduled;
  }

  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() =>
      _dailyTasksDataSource.getTasks();

  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) =>
      _dailyTasksDataSource.saveTasks(tasks);
}
