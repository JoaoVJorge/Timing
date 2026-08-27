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
        groupActivityId: "activity-123",
        id: "grp_activity-123",
      );

      final DailyTaskEntity created = result.getOrElse(
        () => throw StateError("expected task"),
      );
      expect(created.id, "grp_activity-123");
      expect(created.groupId, "group-123");
      expect(created.groupActivityId, "activity-123");
      expect(created.isFromGroup, true);
    });

    test("does not turn a personal goal into the group's goal", () async {
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
        groupActivityId: "activity-123",
      );

      final DailyTaskEntity linked = result.getOrElse(
        () => throw StateError("expected task"),
      );
      expect(linked.id, isNot("existing"));
      expect(linked.isFromGroup, true);
      expect(repository.savedTasks, hasLength(2));
      expect(repository.savedTasks?.first.groupId, isNull);
      expect(repository.savedTasks?.last.groupId, "group-123");
      expect(repository.savedTasks?.last.groupActivityId, "activity-123");
    });

    test("reuses the canonical copy of the same group goal", () async {
      final DailyTaskEntity canonical = DailyTaskEntity(
        id: "grp_activity-123",
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        completedDates: const ["2026-08-26"],
        groupId: "group-123",
        groupActivityId: "activity-123",
      );
      final repository = _FakeDailyTasksRepository([canonical]);
      final useCase = AddDailyTaskUseCase(dailyTasksRepository: repository);

      final result = await useCase(
        name: "Estudar",
        colorValue: 1,
        targetDays: 5,
        sequenceType: DailyTaskSequenceType.casual,
        reuseMatchingTask: true,
        groupId: "group-123",
        groupActivityId: "activity-123",
        id: "grp_activity-123",
      );

      expect(
        result.getOrElse(() => throw StateError("expected task")),
        canonical,
      );
      expect(repository.savedTasks, isNull);
    });
  });
}
