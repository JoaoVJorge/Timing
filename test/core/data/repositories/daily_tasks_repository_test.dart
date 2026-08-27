import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";

class _UnusedDailyTasksDataSource implements DailyTasksDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test("daily-task mutations execute in their original order", () async {
    final DailyTasksRepository repository = DailyTasksRepository(
      dailyTasksDataSource: _UnusedDailyTasksDataSource(),
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
    final DailyTasksRepository repository = DailyTasksRepository(
      dailyTasksDataSource: _UnusedDailyTasksDataSource(),
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
