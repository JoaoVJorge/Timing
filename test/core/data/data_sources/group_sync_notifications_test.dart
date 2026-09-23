import "dart:async";
import "dart:io";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/auth/offline_grace_period.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

class _Storage implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object?> values = {};
  @override
  Future<T?> read<T>(LocalStorageKeys key) async => values[key] as T?;
  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Backend implements SupabaseService {
  _Backend(this.requireClient);
  bool offline = false;
  @override
  final SupabaseClient requireClient;
  @override
  String get currentUserId => "user-1";
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Logger implements AppLoggerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test("offline access expires after seven days", () {
    final now = DateTime.utc(2026, 9, 22);
    const period = OfflineGracePeriod();
    expect(
      period.hasExpired(
        lastVerifiedOnlineAt: now.subtract(const Duration(days: 7)),
        now: now,
      ),
      isFalse,
    );
    expect(
      period.hasExpired(
        lastVerifiedOnlineAt: now.subtract(const Duration(days: 7, seconds: 1)),
        now: now,
      ),
      isTrue,
    );
  });

  test("Wi-Fi without backend access stays offline", () async {
    bool reachable = false;
    final service = ConnectivityService(
      checkConnectivity: () async => [ConnectivityResult.wifi],
      checkBackend: () async => reachable,
    );
    await service.refresh();
    expect(service.isOnline.value, isFalse);
    reachable = true;
    await service.refresh();
    expect(service.isOnline.value, isTrue);
    service.dispose();
  });

  late HttpServer server;
  late _Backend backend;
  late _Storage storage;
  late PendingSyncStore pending;
  late ActivityChangeBus bus;
  late List<GroupActivityChange> changes;
  late StreamSubscription<GroupActivityChange> subscription;
  late Future<void> Function(HttpRequest) respond;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    backend = _Backend(
      SupabaseClient("http://127.0.0.1:${server.port}", "test"),
    );
    storage = _Storage();
    pending = PendingSyncStore(localStorageService: storage);
    bus = ActivityChangeBus();
    changes = [];
    subscription = bus.stream.listen(changes.add);
    respond = (request) async {
      await request.drain<void>();
      request.response.headers.contentType = ContentType.json;
      request.response.statusCode = backend.offline ? 400 : 200;
      request.response.write(
        backend.offline ? '{"message":"unavailable","code":"test"}' : '[]',
      );
      await request.response.close();
    };
    server.listen((request) => unawaited(respond(request)));
  });

  test("authentication responses still mean internet is available", () async {
    for (final int status in [401, 404]) {
      respond = (request) async {
        await request.drain<void>();
        request.response.statusCode = status;
        await request.response.close();
      };
      final bool reachable = await ConnectivityService.probeBackend(
        Uri.parse("http://127.0.0.1:${server.port}/auth/v1/health"),
      );
      expect(reachable, isTrue);
    }
  });

  tearDown(() async {
    await subscription.cancel();
    bus.dispose();
    await backend.requireClient.dispose();
    await server.close(force: true);
  });

  DailyTasksDataSource dailyTasks() => DailyTasksDataSource(
    localStorageService: storage,
    supabaseService: backend,
    logger: _Logger(),
    pendingSyncStore: pending,
    activityChangeBus: bus,
  );

  const task = DailyTaskEntity(
    id: "goal-1",
    name: "Study",
    colorValue: 1,
    targetDays: 30,
    completedDates: ["2026-09-21"],
    groupId: "group-1",
  );

  test(
    "local goal save returns first; server confirmation refreshes groups",
    () async {
      final source = dailyTasks();
      final received = Completer<void>();
      final release = Completer<void>();
      final normalResponse = respond;
      respond = (request) async {
        received.complete();
        await release.future;
        await normalResponse(request);
      };
      final result = await source.saveTasks([task]);
      expect(result.isRight(), isTrue);
      expect(storage.values[LocalStorageKeys.dailyTasks], isNotNull);
      await received.future;
      expect(changes, isEmpty);
      final notified = bus.stream.first;
      release.complete();
      await notified.timeout(const Duration(seconds: 5));
      expect(changes, hasLength(1));
    },
  );

  test(
    "failed goal upload stays pending; reconnect refreshes groups",
    () async {
      final source = dailyTasks();
      backend.offline = true;
      await source.saveTasks([task]);
      // Flush also waits behind the original background upload.
      await source.flushPendingSync();
      expect(changes, isEmpty);
      expect(pending.contains(PendingSyncDataset.dailyTasks), isTrue);
      backend.offline = false;
      final notified = bus.stream.first;
      await source.flushPendingSync();
      await notified;
      expect(pending.contains(PendingSyncDataset.dailyTasks), isFalse);
    },
  );

  test("queued focus activity refreshes groups after reconnect", () async {
    final source = ActivityDataSource(
      supabaseService: backend,
      localStorageService: storage,
      pendingSyncStore: pending,
      logger: _Logger(),
      activityChangeBus: bus,
    );
    backend.offline = true;
    await source.logActivity(
      category: TimeCategoryType.studying,
      subjectId: "subject-1",
      subjectName: "Study",
      seconds: 60,
    );
    expect(changes, isEmpty);
    expect(pending.contains(PendingSyncDataset.activityEntries), isTrue);
    backend.offline = false;
    final notified = bus.stream.first;
    await source.flushPendingSync();
    await notified;
    expect(pending.contains(PendingSyncDataset.activityEntries), isFalse);
    expect(changes, hasLength(1));
    await source.flushPendingSync();
    expect(changes, hasLength(1));
  });

  test("group activity survives restart and syncs after reconnect", () async {
    backend.offline = true;
    final activity = ActivityDataSource(
      supabaseService: backend,
      localStorageService: storage,
      pendingSyncStore: pending,
      logger: _Logger(),
      activityChangeBus: bus,
    );
    final goals = dailyTasks();

    await activity.logActivity(
      category: TimeCategoryType.studying,
      subjectId: "group-subject",
      subjectName: "Group study",
      seconds: 600,
    );
    await goals.saveTasks([task]);
    await goals.flushPendingSync();
    expect(
      pending.all,
      containsAll([
        PendingSyncDataset.activityEntries,
        PendingSyncDataset.dailyTasks,
      ]),
    );

    // New store and data sources simulate a fresh app process using the same
    // persisted local storage.
    final restoredPending = PendingSyncStore(localStorageService: storage);
    await restoredPending.load();
    final restoredActivity = ActivityDataSource(
      supabaseService: backend,
      localStorageService: storage,
      pendingSyncStore: restoredPending,
      logger: _Logger(),
      activityChangeBus: bus,
    );
    final restoredGoals = DailyTasksDataSource(
      localStorageService: storage,
      supabaseService: backend,
      logger: _Logger(),
      pendingSyncStore: restoredPending,
      activityChangeBus: bus,
    );
    backend.offline = false;
    await restoredGoals.flushPendingSync();
    await restoredActivity.flushPendingSync();
    await Future<void>.delayed(Duration.zero);

    expect(restoredPending.all, isEmpty);
    expect(storage.values[LocalStorageKeys.pendingActivityEntries], "[]");
    expect(changes, isNotEmpty);
  });
}
