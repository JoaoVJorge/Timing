import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
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

/// Signed-in user whose backend is unreachable: `requireClient` throws, as it
/// would offline.
class _OfflineSupabase implements SupabaseService {
  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient => throw StateError("offline");

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Backend that is reachable but rejects every write for good.
class _RejectingSupabase implements SupabaseService {
  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient =>
      throw const PostgrestException(message: "rejected", code: "23514");

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _SignedOutSupabase implements SupabaseService {
  @override
  String? get currentUserId => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<(ActivityDataSource, PendingSyncStore, _MemStorage)> _build(
  SupabaseService supabase,
) async {
  final storage = _MemStorage();
  final store = PendingSyncStore(localStorageService: storage);
  await store.load();
  final dataSource = ActivityDataSource(
    supabaseService: supabase,
    localStorageService: storage,
    pendingSyncStore: store,
    logger: AppLoggerService(),
  );
  return (dataSource, store, storage);
}

void main() {
  group("ActivityDataSource offline sync", () {
    test(
      "queues the session and marks pending when the remote sync fails",
      () async {
        final (dataSource, store, storage) = await _build(_OfflineSupabase());

        final result = await dataSource.logActivity(
          category: TimeCategoryType.studying,
          subjectId: "s1",
          subjectName: "Matemática",
          seconds: 1800,
        );

        expect(result.isRight(), isTrue);
        expect(store.contains(PendingSyncDataset.activityEntries), isTrue);
        final String? saved =
            storage.data[LocalStorageKeys.pendingActivityEntries] as String?;
        expect(saved, isNotNull);
        final List<dynamic> queue = jsonDecode(saved!) as List<dynamic>;
        expect(queue, hasLength(1));
        expect(queue.single["seconds"], 1800);
      },
    );

    test(
      "accumulates multiple failed sessions instead of overwriting",
      () async {
        final (dataSource, store, storage) = await _build(_OfflineSupabase());

        await dataSource.logActivity(
          category: TimeCategoryType.studying,
          subjectId: "s1",
          subjectName: "Matemática",
          seconds: 600,
        );
        await dataSource.logActivity(
          category: TimeCategoryType.reading,
          subjectId: "s2",
          subjectName: "Livro",
          pages: 5,
        );

        final String saved =
            storage.data[LocalStorageKeys.pendingActivityEntries] as String;
        final List<dynamic> queue = jsonDecode(saved) as List<dynamic>;
        expect(queue, hasLength(2));
        expect(store.contains(PendingSyncDataset.activityEntries), isTrue);
      },
    );

    test("keeps the dataset pending while the retry still fails", () async {
      final (dataSource, store, _) = await _build(_OfflineSupabase());
      await dataSource.logActivity(
        category: TimeCategoryType.studying,
        subjectId: "s1",
        subjectName: "Matemática",
        seconds: 1800,
      );

      await dataSource.flushPendingSync();

      expect(store.contains(PendingSyncDataset.activityEntries), isTrue);
    });

    test("does not queue when there is no signed-in user", () async {
      final (dataSource, store, storage) = await _build(_SignedOutSupabase());

      final result = await dataSource.logActivity(
        category: TimeCategoryType.studying,
        subjectId: "s1",
        subjectName: "Matemática",
        seconds: 1800,
      );

      expect(result.isRight(), isTrue);
      expect(store.contains(PendingSyncDataset.activityEntries), isFalse);
      expect(storage.data[LocalStorageKeys.pendingActivityEntries], isNull);
    });

    test("does not queue a no-op call (zero seconds/pages/tasks)", () async {
      final (dataSource, store, _) = await _build(_OfflineSupabase());

      final result = await dataSource.logActivity(
        category: TimeCategoryType.studying,
        subjectId: "s1",
        subjectName: "Matemática",
      );

      expect(result.isRight(), isTrue);
      expect(store.contains(PendingSyncDataset.activityEntries), isFalse);
    });

    test(
      "drops rows the server permanently rejects instead of blocking",
      () async {
        final (offlineSource, store, storage) = await _build(
          _OfflineSupabase(),
        );
        for (final id in ["s1", "s2"]) {
          await offlineSource.logActivity(
            category: TimeCategoryType.studying,
            subjectId: id,
            subjectName: id,
            seconds: 60,
          );
        }
        expect(store.contains(PendingSyncDataset.activityEntries), isTrue);

        final rejecting = ActivityDataSource(
          supabaseService: _RejectingSupabase(),
          localStorageService: storage,
          pendingSyncStore: store,
          logger: AppLoggerService(),
        );
        await rejecting.flushPendingSync();

        expect(store.contains(PendingSyncDataset.activityEntries), isFalse);
        final String queue =
            storage.data[LocalStorageKeys.pendingActivityEntries] as String;
        expect(jsonDecode(queue), isEmpty);
      },
    );
  });
}
