import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";

class _NoopSubjectsDataSource implements SubjectsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test("subject mutations execute in their original order", () async {
    final SubjectsRepository repository = SubjectsRepository(
      subjectsDataSource: _NoopSubjectsDataSource(),
    );
    final Completer<void> releaseFirst = Completer<void>();
    final List<String> events = <String>[];

    final Future<int> first = repository.runSerializedMutation(() async {
      events.add("first-start");
      await releaseFirst.future;
      events.add("first-end");
      return 1;
    });
    final Future<int> second = repository.runSerializedMutation(() async {
      events.add("second-start");
      events.add("second-end");
      return 2;
    });

    await Future<void>.delayed(Duration.zero);
    expect(events, <String>["first-start"]);

    releaseFirst.complete();
    expect(await Future.wait<int>(<Future<int>>[first, second]), <int>[1, 2]);
    expect(events, <String>[
      "first-start",
      "first-end",
      "second-start",
      "second-end",
    ]);
  });
}
