import "dart:async";
import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
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
  final List<http.Request> requests = <http.Request>[];
  int busNotifications = 0;

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

  ActivityRepository sourceOn(SupabaseService supabase) => ActivityRepository(
    activityDataSource: ActivityDataSource(supabaseService: supabase),
    localStorageService: storage,
    pendingSyncStore: store,
    logger: AppLoggerService(),
    activityChangeBus: bus,
  );

  /// A backend that answers every request with [status] (and records it).
  ActivityRepository sourceOnline({
    int status = 204,
    Object? body,
    String userId = "user-1",
  }) {
    final TestBackend backend = TestBackend((request) async {
      requests.add(request);
      return jsonResponse(request, body, status);
    });
    addTearDown(backend.dispose);
    return sourceOn(TestSupabaseService(backend.client, userId: userId));
  }

  List<http.Request> get deletes =>
      requests.where((request) => request.method == "DELETE").toList();

  void seedQueue(List<Map<String, dynamic>> rows) {
    storage.data[LocalStorageKeys.pendingActivityEntries] = jsonEncode(rows);
  }

  List<dynamic> get queue =>
      jsonDecode(
            storage.data[LocalStorageKeys.pendingActivityEntries] as String? ??
                "[]",
          )
          as List<dynamic>;

  Map<String, dynamic> get pendingClears =>
      jsonDecode(
            storage.data[LocalStorageKeys.pendingActivityClears] as String? ??
                "{}",
          )
          as Map<String, dynamic>;
}

Map<String, dynamic> _queuedRow(String subjectId) => {
  "id": "id-$subjectId",
  "user_id": "user-1",
  "category": "studying",
  "subject_id": subjectId,
  "subject_name": subjectId,
  "seconds": 60,
  "pages": 0,
  "completed_tasks": 0,
  "occurred_at": DateTime.now().toUtc().toIso8601String(),
};

/// Lets the background flush that a clear starts run to its end.
Future<void> _settle() async {
  for (int i = 0; i < 40; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group("ActivityRepository.clearSubjectEntries", () {
    test("deletes that subject's sessions on the backend", () async {
      final _Rig rig = await _Rig.create();
      final ActivityRepository dataSource = rig.sourceOnline();

      final result = await dataSource.clearSubjectEntries("s1");
      await _settle();

      expect(result.isRight(), isTrue);
      expect(rig.deletes, hasLength(1));
      final Uri url = rig.deletes.single.url;
      expect(url.path, endsWith("/activity_entries"));
      expect(url.queryParameters["user_id"], "eq.user-1");
      expect(url.queryParameters["subject_id"], "eq.s1");
    });

    test(
      "only removes what was logged up to the moment it was asked",
      () async {
        final _Rig rig = await _Rig.create();
        final ActivityRepository dataSource = rig.sourceOnline();
        final DateTime before = DateTime.now().toUtc();

        await dataSource.clearSubjectEntries("s1");
        await _settle();

        final String bound =
            rig.deletes.single.url.queryParameters["occurred_at"]!;
        expect(bound, startsWith("lte."));
        final DateTime cutoff = DateTime.parse(bound.substring(4));
        // A session logged afterwards is later than the cutoff, so it stays.
        expect(
          cutoff.isBefore(before.subtract(const Duration(seconds: 1))),
          isFalse,
        );
        expect(
          cutoff.isAfter(
            DateTime.now().toUtc().add(const Duration(seconds: 1)),
          ),
          isFalse,
        );
      },
    );

    test("leaves nothing pending once the delete went through", () async {
      final _Rig rig = await _Rig.create();
      final ActivityRepository dataSource = rig.sourceOnline();

      await dataSource.clearSubjectEntries("s1");
      await _settle();

      expect(rig.store.contains(PendingSyncDataset.activityEntries), isFalse);
      expect(rig.pendingClears, isEmpty);
    });

    test("tells the groups once the sessions are gone", () async {
      final _Rig rig = await _Rig.create();
      final ActivityRepository dataSource = rig.sourceOnline();

      await dataSource.clearSubjectEntries("s1");
      await _settle();

      expect(rig.busNotifications, 1);
    });

    test("drops the sessions still queued for it, keeps the others", () async {
      final _Rig rig = await _Rig.create();
      rig.seedQueue([_queuedRow("s1"), _queuedRow("s2"), _queuedRow("s1")]);
      final ActivityRepository dataSource = rig.sourceOn(_OfflineSupabase());

      await dataSource.clearSubjectEntries("s1");

      expect(rig.queue.map((row) => row["subject_id"]), ["s2"]);
    });

    test("offline: remembers the delete and keeps it pending", () async {
      final _Rig rig = await _Rig.create();
      final ActivityRepository dataSource = rig.sourceOn(_OfflineSupabase());

      final result = await dataSource.clearSubjectEntries("s1");
      await _settle();

      expect(result.isRight(), isTrue);
      expect(rig.store.contains(PendingSyncDataset.activityEntries), isTrue);
      expect(rig.pendingClears.keys, ["s1"]);
    });

    test("sends the remembered delete once the backend is reachable", () async {
      final _Rig rig = await _Rig.create();
      await rig.sourceOn(_OfflineSupabase()).clearSubjectEntries("s1");
      await _settle();
      expect(rig.pendingClears, isNotEmpty);

      await rig.sourceOnline().flushPendingSync();

      expect(rig.deletes, hasLength(1));
      expect(rig.deletes.single.url.queryParameters["subject_id"], "eq.s1");
      expect(rig.pendingClears, isEmpty);
      expect(rig.store.contains(PendingSyncDataset.activityEntries), isFalse);
    });

    test("asking twice keeps the later moment for the retry", () async {
      final _Rig rig = await _Rig.create();
      final ActivityRepository offline = rig.sourceOn(_OfflineSupabase());

      await offline.clearSubjectEntries("s1");
      await _settle();
      final DateTime first = DateTime.parse(rig.pendingClears["s1"] as String);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await offline.clearSubjectEntries("s1");
      await _settle();
      final DateTime second = DateTime.parse(rig.pendingClears["s1"] as String);

      expect(second.isAfter(first), isTrue);
    });

    test(
      "a delete the server refuses for good is dropped, not retried",
      () async {
        final _Rig rig = await _Rig.create();
        rig.seedQueue([_queuedRow("s2")]);
        await rig.sourceOn(_OfflineSupabase()).clearSubjectEntries("s1");
        await _settle();

        await rig
            .sourceOnline(
              status: 403,
              body: {"code": "42501", "message": "denied"},
            )
            .flushPendingSync();

        // The refused delete does not stay at the head of the queue forever.
        expect(rig.pendingClears, isEmpty);
      },
    );

    test("signed out: only the local queue is touched", () async {
      final _Rig rig = await _Rig.create();
      rig.seedQueue([_queuedRow("s1")]);
      final ActivityRepository dataSource = rig.sourceOn(_SignedOutSupabase());

      final result = await dataSource.clearSubjectEntries("s1");
      await _settle();

      expect(result.isRight(), isTrue);
      expect(rig.queue, isEmpty);
      expect(rig.pendingClears, isEmpty);
      expect(rig.store.contains(PendingSyncDataset.activityEntries), isFalse);
    });
  });
}
