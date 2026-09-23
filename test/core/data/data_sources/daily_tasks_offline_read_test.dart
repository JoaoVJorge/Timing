import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

class _MemStorage implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object?> data = {};

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => data[key] as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    data[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _CountingSupabase implements SupabaseService {
  int clientRequests = 0;

  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient {
    clientRequests++;
    throw StateError("offline");
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<(DailyTasksDataSource, _CountingSupabase)> _build({
  required bool reachable,
}) async {
  final storage = _MemStorage()..data[LocalStorageKeys.dailyTasks] = "[]";
  final store = PendingSyncStore(localStorageService: storage);
  await store.load();
  final supabase = _CountingSupabase();
  final dataSource = DailyTasksDataSource(
    localStorageService: storage,
    supabaseService: supabase,
    logger: AppLoggerService(),
    pendingSyncStore: store,
    isBackendReachable: () => reachable,
  );
  return (dataSource, supabase);
}

void main() {
  group("DailyTasksDataSource reads", () {
    test("skip the remote refresh while the backend is unreachable", () async {
      final (dataSource, supabase) = await _build(reachable: false);

      final result = await dataSource.getTasks();

      expect(result.isRight(), isTrue);
      expect(supabase.clientRequests, 0);
    });

    test("refresh from the backend while it is reachable", () async {
      final (dataSource, supabase) = await _build(reachable: true);

      await dataSource.getTasks();

      expect(supabase.clientRequests, 1);
    });
  });
}
