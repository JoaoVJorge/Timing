import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/offline_action_queue.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

const _rejected = PostgrestException(message: "rejected", code: "23505");

class _Rig {
  _Rig() {
    queue = OfflineActionQueue(
      localStorageService: storage,
      pendingSyncStore: pending,
      logger: AppLoggerService(),
      storageKey: LocalStorageKeys.pendingGroupActions,
      dataset: PendingSyncDataset.groups,
      label: "group action",
    );
  }

  final MemoryStorage storage = MemoryStorage();
  late final PendingSyncStore pending = PendingSyncStore(
    localStorageService: storage,
  );
  late final OfflineActionQueue queue;

  List<dynamic> get stored =>
      jsonDecode(storage.data[LocalStorageKeys.pendingGroupActions] as String)
          as List<dynamic>;

  Future<void> enqueueAll(List<String> ids) async {
    for (final String id in ids) {
      await queue.enqueue({"id": id});
    }
  }
}

void main() {
  test("enqueueing keeps the order and marks the dataset pending", () async {
    final rig = _Rig();

    await rig.enqueueAll(["a", "b"]);

    expect(rig.stored.map((action) => action["id"]), ["a", "b"]);
    expect(rig.pending.contains(PendingSyncDataset.groups), isTrue);
  });

  test("a flush that gets everything through leaves nothing pending", () async {
    final rig = _Rig();
    await rig.enqueueAll(["a", "b"]);
    final List<String> applied = [];

    final int processed = await rig.queue.flush(
      (action) async => applied.add(action["id"] as String),
    );

    expect(processed, 2);
    expect(applied, ["a", "b"]);
    expect(rig.stored, isEmpty);
    expect(rig.pending.contains(PendingSyncDataset.groups), isFalse);
  });

  test(
    "a transient failure stops the pass and keeps the rest in order",
    () async {
      final rig = _Rig();
      await rig.enqueueAll(["a", "b", "c"]);
      final List<String> attempted = [];

      final int processed = await rig.queue.flush((action) async {
        attempted.add(action["id"] as String);
        if (action["id"] == "b") {
          throw StateError("offline");
        }
      });

      expect(processed, 1);
      // "c" must not run ahead of "b".
      expect(attempted, ["a", "b"]);
      expect(rig.stored.map((action) => action["id"]), ["b", "c"]);
      expect(rig.pending.contains(PendingSyncDataset.groups), isTrue);
    },
  );

  test(
    "an action the server refuses for good is dropped, not retried",
    () async {
      final rig = _Rig();
      await rig.enqueueAll(["a", "b", "c"]);
      final List<String> applied = [];

      final int processed = await rig.queue.flush((action) async {
        if (action["id"] == "b") {
          throw _rejected;
        }
        applied.add(action["id"] as String);
      });

      expect(processed, 3);
      expect(applied, ["a", "c"]);
      expect(rig.stored, isEmpty);
      expect(rig.pending.contains(PendingSyncDataset.groups), isFalse);
    },
  );

  test("replay tells what was applied apart from what was dropped", () async {
    final rig = _Rig();

    final OfflineReplayResult result = await rig.queue.replay(
      [
        {"id": "a"},
        {"id": "b"},
        {"id": "c"},
        {"id": "d"},
      ],
      (action) async {
        if (action["id"] == "b") {
          throw _rejected;
        }
        if (action["id"] == "d") {
          throw StateError("offline");
        }
      },
    );

    expect(result.processed, 3);
    expect(result.applied, 2);
  });

  test("flush does nothing while the dataset is not pending", () async {
    final rig = _Rig();
    await rig.queue.write([
      {"id": "a"},
    ]);
    int calls = 0;

    final int processed = await rig.queue.flush((_) async => calls++);

    expect(processed, 0);
    expect(calls, 0);
    expect(rig.stored, hasLength(1));
  });

  test("a pending mark with an empty queue is cleared", () async {
    final rig = _Rig();
    await rig.pending.markPending(PendingSyncDataset.groups);

    await rig.queue.flush((_) async {});

    expect(rig.pending.contains(PendingSyncDataset.groups), isFalse);
  });

  test("an unreadable queue is treated as empty", () async {
    final rig = _Rig();
    rig.storage.data[LocalStorageKeys.pendingGroupActions] = "not json";

    expect(await rig.queue.read(), isEmpty);
  });
}
