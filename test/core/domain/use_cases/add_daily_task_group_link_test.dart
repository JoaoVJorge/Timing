import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_daily_task_use_case.dart";

class _FakeDailyTasksRepository implements DailyTasksRepository {
  _FakeDailyTasksRepository(this._tasks);

  List<DailyTaskEntity> _tasks;
  List<DailyTaskEntity>? savedTasks;

  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async =>
      Right(_tasks);

  @override
  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) async {
    savedTasks = tasks;
    _tasks = tasks;
    return const Right(null);
  }
}

void main() {
  group("AddDailyTaskUseCase group link", () {
    test("stamps groupId on a freshly created group goal", () async {
      final repository = _FakeDailyTasksRepository([]);
      final useCase = AddDailyTaskUseCase(dailyTasksRepository: repository);

      final result = await useCase(
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        sequenceType: DailyTaskSequenceType.casual,
        groupId: "group-123",
      );

      final DailyTaskEntity created =
          result.getOrElse(() => throw StateError("expected task"));
      expect(created.groupId, "group-123");
      expect(created.isFromGroup, true);
    });

    test("links an existing goal to the group when reused", () async {
      final repository = _FakeDailyTasksRepository([
        DailyTaskEntity(
          id: "existing",
          name: "Estudar",
          colorValue: 1,
          targetDays: 5,
          completedDates: const [],
        ),
      ]);
      final useCase = AddDailyTaskUseCase(dailyTasksRepository: repository);

      final result = await useCase(
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        sequenceType: DailyTaskSequenceType.casual,
        reuseMatchingTask: true,
        groupId: "group-123",
      );

      final DailyTaskEntity linked =
          result.getOrElse(() => throw StateError("expected task"));
      expect(linked.id, "existing");
      expect(linked.isFromGroup, true);
      // Persisted, not just returned.
      expect(repository.savedTasks?.single.groupId, "group-123");
    });
  });
}
