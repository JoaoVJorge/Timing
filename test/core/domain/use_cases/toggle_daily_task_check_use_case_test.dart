import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";

class _FakeDailyTasksRepository implements DailyTasksRepository {
  _FakeDailyTasksRepository(this.tasks);

  List<DailyTaskEntity> tasks;
  int getMutationTasksCalls = 0;
  List<DailyTaskEntity>? savedTasks;

  @override
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) =>
      mutation();

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getLocalTasks() async {
    return Right(tasks);
  }

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasksForMutation() async {
    getMutationTasksCalls++;
    return Right(tasks);
  }

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async =>
      Right(tasks);

  @override
  Future<Either<AppError, void>> saveTasks(
    List<DailyTaskEntity> updatedTasks,
  ) async {
    savedTasks = updatedTasks;
    tasks = updatedTasks;
    return const Right(null);
  }
}

void main() {
  test("hydrates mutation state before a toggle", () async {
    final DailyTaskEntity task = const DailyTaskEntity(
      id: "goal-1",
      name: "Meta",
      colorValue: 1,
      targetDays: 14,
      completedDates: [],
    );
    final _FakeDailyTasksRepository repository = _FakeDailyTasksRepository([
      task,
    ]);
    final ToggleDailyTaskCheckUseCase useCase = ToggleDailyTaskCheckUseCase(
      dailyTasksRepository: repository,
    );

    final Either<AppError, DailyTaskEntity> result = await useCase(
      taskId: task.id,
    );

    expect(repository.getMutationTasksCalls, 1);
    expect(repository.savedTasks?.single.isCheckedToday, true);
    expect(
      result.getOrElse(() => throw StateError("expected task")).isCheckedToday,
      true,
    );
  });
}
