import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

class _UnusedDailyTasksDataSource implements DailyTasksDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A signed-in backend whose read of the goals waits until it is released.
class _ControllableReadDataSource implements DailyTasksDataSource {
  final Completer<void> readStarted = Completer<void>();
  final Completer<void> releaseRead = Completer<void>();

  @override
  String? get currentUserId => "user-1";

  @override
  Future<List<DailyTaskEntity>> fetchTasks(String userId) async {
    readStarted.complete();
    await releaseRead.future;
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DailyTasksRepository _repository(DailyTasksDataSource dataSource) {
  final MemoryStorage storage = MemoryStorage();
  return DailyTasksRepository(
    dailyTasksDataSource: dataSource,
    localStorageService: storage,
    logger: AppLoggerService(),
    pendingSyncStore: PendingSyncStore(localStorageService: storage),
  );
}

void main() {
  test("remote hydration is serialized before a mutation", () async {
    final dataSource = _ControllableReadDataSource();
    final repository = _repository(dataSource);
    bool mutationStarted = false;

    final Future<Either<AppError, List<DailyTaskEntity>>> read = repository
        .getTasks();
    await dataSource.readStarted.future;
    final Future<void> mutation = repository.runSerializedMutation(() async {
      mutationStarted = true;
    });

    await Future<void>.delayed(Duration.zero);
    expect(mutationStarted, isFalse);

    dataSource.releaseRead.complete();
    await Future.wait([read, mutation]);
    expect(mutationStarted, isTrue);
  });

  test("daily-task mutations execute in their original order", () async {
    final DailyTasksRepository repository = _repository(
      _UnusedDailyTasksDataSource(),
    );
    final Completer<void> releaseFirst = Completer<void>();
    final List<String> events = [];

    final Future<void> first = repository.runSerializedMutation(() async {
      events.add("first-start");
      await releaseFirst.future;
      events.add("first-end");
    });
    final Future<void> second = repository.runSerializedMutation(() async {
      events.add("second-start");
      events.add("second-end");
    });

    await Future<void>.delayed(Duration.zero);
    expect(events, ["first-start"]);

    releaseFirst.complete();
    await Future.wait([first, second]);

    expect(events, ["first-start", "first-end", "second-start", "second-end"]);
  });

  test("a failed mutation does not poison the queue", () async {
    final DailyTasksRepository repository = _repository(
      _UnusedDailyTasksDataSource(),
    );
    bool secondRan = false;

    final Future<void> first = repository.runSerializedMutation(() async {
      throw StateError("failed");
    });
    final Future<void> second = repository.runSerializedMutation(() async {
      secondRan = true;
    });

    await expectLater(first, throwsStateError);
    await second;

    expect(secondRan, isTrue);
  });
}
