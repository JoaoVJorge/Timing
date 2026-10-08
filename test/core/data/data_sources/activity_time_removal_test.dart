import "dart:async";
import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

/// Signed-in user whose backend cannot be reached.
class _OfflineSupabase implements SupabaseService {
  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient => throw StateError("offline");

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _SignedOutSupabase implements SupabaseService {
  @override
  String? get currentUserId => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Rig {
  _Rig._(this.storage, this.store, this.bus);

  final MemoryStorage storage;
  final PendingSyncStore store;
  final ActivityChangeBus bus;

  /// Every RPC the backend received, as "function name" in order.
  final List<String> calls = <String>[];
  final List<Map<String, dynamic>> removalBodies = <Map<String, dynamic>>[];
  int busNotifications = 0;

  /// The status the backend answers a removal with, and its error body.
  int removalStatus = 204;
  Object? removalError;

  static Future<_Rig> create() async {
    final MemoryStorage storage = MemoryStorage();
    final PendingSyncStore store = PendingSyncStore(
      localStorageService: storage,
    );
    await store.load();
    final _Rig rig = _Rig._(storage, store, ActivityChangeBus());
    final StreamSubscription<GroupActivityChange> subscription = rig.bus.stream
        .listen((_) => rig.busNotifications++);
    addTearDown(subscription.cancel);
    return rig;
  }

  ActivityDataSource sourceOn(SupabaseService supabase) => ActivityDataSource(
    supabaseService: supabase,
    localStorageService: storage,
    pendingSyncStore: store,
    logger: AppLoggerService(),
    activityChangeBus: bus,
  );

  ActivityDataSource sourceOnline() {
    final TestBackend backend = TestBackend((request) async {
      final String function = request.url.pathSegments.last;
      calls.add(function);
      if (function == "remove_activity_seconds") {
        removalBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return jsonResponse(request, removalError, removalStatus);
      }
      return http.Response("", 204, request: request);
    });
    addTearDown(backend.dispose);
    return sourceOn(TestSupabaseService(backend.client));
  }

  void seedQueue(List<Map<String, dynamic>> rows) {
    storage.data[LocalStorageKeys.pendingActivityEntries] = jsonEncode(rows);
  }

  List<dynamic> get pendingRemovals =>
      jsonDecode(
            storage.data[LocalStorageKeys.pendingActivityRemovals] as String? ??
                "[]",
          )
          as List<dynamic>;

  bool get isPending => store.contains(PendingSyncDataset.activityEntries);
}

Map<String, dynamic> _queuedRow(String subjectId) => {
  "id": "00000000-0000-4000-8000-00000000000${subjectId.length}",
  "user_id": "user-1",
  "category": "studying",
  "subject_id": subjectId,
  "subject_name": subjectId,
  "seconds": 60,
  "pages": 0,
  "completed_tasks": 0,
  "occurred_at": DateTime.now().toUtc().toIso8601String(),
};

/// Lets the background flush that a removal starts run to its end.
Future<void> _settle() async {
  for (int i = 0; i < 40; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group("ActivityDataSource.removeSubjectSeconds", () {
    test("asks the backend to take the time off that activity", () async {
      final _Rig rig = await _Rig.create();
      final ActivityDataSource dataSource = rig.sourceOnline();
      final DateTime before = DateTime.now().toUtc();

      final result = await dataSource.removeSubjectSeconds(
        subjectId: "s1",
        seconds: 600,
      );
      await _settle();

      expect(result.isRight(), isTrue);
      final Map<String, dynamic> body = rig.removalBodies.single;
      expect(body["entry_subject_id"], "s1");
      expect(body["seconds_to_remove"], 600);
      expect(body["removal_id"], hasLength(36));
      // Dated when it was asked, so later sessions are left alone.
      final DateTime removedAt = DateTime.parse(body["removed_at"] as String);
      expect(
        removedAt.isBefore(before.subtract(const Duration(seconds: 1))),
        isFalse,
      );
    });

    test("leaves nothing pending once it went through", () async {
      final _Rig rig = await _Rig.create();
      final ActivityDataSource dataSource = rig.sourceOnline();

      await dataSource.removeSubjectSeconds(subjectId: "s1", seconds: 600);
      await _settle();

      expect(rig.pendingRemovals, isEmpty);
      expect(rig.isPending, isFalse);
      expect(rig.busNotifications, 1);
    });

    test("goes after the sessions still waiting to upload", () async {
      final _Rig rig = await _Rig.create();
      rig.seedQueue([_queuedRow("s1")]);
      await rig.store.markPending(PendingSyncDataset.activityEntries);
      final ActivityDataSource dataSource = rig.sourceOnline();

      await dataSource.removeSubjectSeconds(subjectId: "s1", seconds: 30);
      await _settle();

      // The backend can only shorten a session it already has.
      expect(rig.calls, ["record_activity_entry", "remove_activity_seconds"]);
      expect(rig.isPending, isFalse);
    });

    test("offline it waits, and is sent with the same id later", () async {
      final _Rig rig = await _Rig.create();

      final result = await rig
          .sourceOn(_OfflineSupabase())
          .removeSubjectSeconds(subjectId: "s1", seconds: 600);
      await _settle();

      expect(result.isRight(), isTrue);
      expect(rig.isPending, isTrue);
      final String queuedId =
          (rig.pendingRemovals.single as Map<String, dynamic>)["id"] as String;

      await rig.sourceOnline().flushPendingSync();

      // The id is what lets the backend ignore a request it already applied.
      expect(rig.removalBodies.single["removal_id"], queuedId);
      expect(rig.pendingRemovals, isEmpty);
      expect(rig.isPending, isFalse);
    });

    test("a backend that is not answering keeps the request", () async {
      final _Rig rig = await _Rig.create();
      rig.removalStatus = 503;
      final ActivityDataSource dataSource = rig.sourceOnline();

      await dataSource.removeSubjectSeconds(subjectId: "s1", seconds: 600);
      await _settle();

      expect(rig.pendingRemovals, hasLength(1));
      expect(rig.isPending, isTrue);

      rig.removalStatus = 204;
      await dataSource.flushPendingSync();

      expect(rig.removalBodies, hasLength(2));
      expect(
        rig.removalBodies.first["removal_id"],
        rig.removalBodies.last["removal_id"],
      );
      expect(rig.pendingRemovals, isEmpty);
    });

    test("a request the server refuses for good is dropped, not retried "
        "forever", () async {
      final _Rig rig = await _Rig.create();
      rig
        ..removalStatus = 403
        ..removalError = {"code": "42501", "message": "denied"};
      final ActivityDataSource dataSource = rig.sourceOnline();

      await dataSource.removeSubjectSeconds(subjectId: "s1", seconds: 600);
      await _settle();

      expect(rig.pendingRemovals, isEmpty);
      expect(rig.isPending, isFalse);
    });

    test("several requests are sent oldest first", () async {
      final _Rig rig = await _Rig.create();
      final ActivityDataSource offline = rig.sourceOn(_OfflineSupabase());
      await offline.removeSubjectSeconds(subjectId: "s1", seconds: 100);
      await offline.removeSubjectSeconds(subjectId: "s2", seconds: 200);
      await _settle();

      await rig.sourceOnline().flushPendingSync();

      expect(rig.removalBodies.map((body) => body["seconds_to_remove"]), [
        100,
        200,
      ]);
    });

    test("signed out, or with nothing to remove, asks for nothing", () async {
      final _Rig rig = await _Rig.create();

      await rig
          .sourceOn(_SignedOutSupabase())
          .removeSubjectSeconds(subjectId: "s1", seconds: 600);
      await rig.sourceOnline().removeSubjectSeconds(
        subjectId: "s1",
        seconds: 0,
      );
      await _settle();

      expect(rig.calls, isEmpty);
      expect(rig.pendingRemovals, isEmpty);
      expect(rig.isPending, isFalse);
    });
  });
}
