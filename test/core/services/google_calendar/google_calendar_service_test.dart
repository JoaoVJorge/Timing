import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/services/google_calendar/google_calendar_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

class AuthService implements SupabaseService {
  String? user = "user-1";
  @override
  bool get isConfigured => true;
  @override
  String? get currentUserId => user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthService auth;
  late MemoryStorage storage;
  late PendingSyncStore outbox;
  late GoogleCalendarService service;
  late List<String> calls;
  late Future<Map<String, dynamic>> Function(String) handler;

  setUp(() async {
    auth = AuthService();
    storage = MemoryStorage();
    storage.data[LocalStorageKeys.googleCalendarEnabled] = true;
    outbox = PendingSyncStore(localStorageService: storage);
    calls = [];
    handler = (_) async => {"connected": true, "timeZone": "America/Fortaleza"};
    service = GoogleCalendarService(
      supabaseService: auth,
      localStorageService: storage,
      pendingSyncStore: outbox,
      invoke: (action) {
        calls.add(action);
        return handler(action);
      },
      launch: (_) async => true,
    );
    await service.initialize();
  });
  tearDown(() => service.onClose());

  test(
    "failed Calendar request remains pending and succeeds on retry",
    () async {
      handler = (_) async => throw StateError("network unavailable");
      await service.sync();
      expect(service.connected.value, isTrue);
      expect(outbox.contains(PendingSyncDataset.googleCalendar), isTrue);
      expect(service.pending.value, isTrue);
      handler = (_) async => {"connected": true};
      await service.sync();
      expect(outbox.contains(PendingSyncDataset.googleCalendar), isFalse);
      expect(service.pending.value, isFalse);
      expect(service.errorCode.value, isEmpty);
    },
  );

  test(
    "does not sync stale backend while Timing has offline changes",
    () async {
      await outbox.markPending(PendingSyncDataset.schedule);
      await service.sync();
      expect(calls, isEmpty);
      expect(outbox.contains(PendingSyncDataset.googleCalendar), isTrue);
      await outbox.clear(PendingSyncDataset.schedule);
      await service.sync();
      expect(calls, ["sync"]);
    },
  );

  test("save during reconciliation schedules a second pass", () async {
    final result = Completer<Map<String, dynamic>>();
    handler = (_) => result.future;
    final first = service.sync();
    final second = service.sync();
    await Future<void>.delayed(Duration.zero);
    expect(calls, ["sync"]);
    result.complete({"connected": true});
    await Future.wait([first, second]);
  });

  test("disconnect disables future sends and clears the outbox", () async {
    await outbox.markPending(PendingSyncDataset.googleCalendar);
    handler = (_) async => {"connected": false};
    await service.disconnect();
    await service.sync();
    expect(calls, ["disconnect"]);
    expect(service.connected.value, isFalse);
    expect(storage.data[LocalStorageKeys.googleCalendarEnabled], isFalse);
    expect(outbox.contains(PendingSyncDataset.googleCalendar), isFalse);
  });

  test(
    "revoked permission requests reconnection without dropping changes",
    () async {
      handler = (_) async => throw const FunctionException(
        status: 503,
        details: {"error": "reconnect_required"},
      );
      await service.sync();
      expect(service.needsReconnect.value, isTrue);
      expect(outbox.contains(PendingSyncDataset.googleCalendar), isTrue);
    },
  );

  test("switching Timing user never reuses previous connection", () async {
    auth.user = "user-2";
    await service.sync();
    expect(calls, isEmpty);
    handler = (_) async => {"connected": false};
    await service.refresh();
    expect(calls, ["status"]);
    expect(service.connected.value, isFalse);
  });

  test("rejects an authorization URL outside Google", () async {
    handler = (_) async => {"url": "https://example.com/oauth"};
    await service.connect();
    expect(service.errorCode.value, "connect_failed");
    expect(service.connecting.value, isFalse);
  });
}
