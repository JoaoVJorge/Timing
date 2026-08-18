import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
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

void main() {
  group("PendingSyncStore", () {
    test("marks and clears datasets, persisting to storage", () async {
      final storage = _MemStorage();
      final store = PendingSyncStore(localStorageService: storage);
      await store.load();

      await store.markPending(PendingSyncDataset.subjects);
      await store.markPending(PendingSyncDataset.schedule);

      expect(store.contains(PendingSyncDataset.subjects), isTrue);
      expect(store.contains(PendingSyncDataset.schedule), isTrue);
      expect(store.contains(PendingSyncDataset.dailyTasks), isFalse);

      await store.clear(PendingSyncDataset.subjects);
      expect(store.contains(PendingSyncDataset.subjects), isFalse);

      final decoded =
          jsonDecode(
                storage.data[LocalStorageKeys.pendingRemoteSyncs] as String,
              )
              as List<dynamic>;
      expect(decoded, [PendingSyncDataset.schedule]);
    });

    test("restores the pending set from storage on load", () async {
      final storage = _MemStorage();
      storage.data[LocalStorageKeys.pendingRemoteSyncs] = jsonEncode([
        PendingSyncDataset.dailyTasks,
      ]);

      final store = PendingSyncStore(localStorageService: storage);
      await store.load();

      expect(store.contains(PendingSyncDataset.dailyTasks), isTrue);
      expect(store.all, {PendingSyncDataset.dailyTasks});
    });

    test("marking the same dataset twice does not rewrite storage", () async {
      final storage = _MemStorage();
      final store = PendingSyncStore(localStorageService: storage);
      await store.load();

      await store.markPending(PendingSyncDataset.subjects);
      storage.data.remove(LocalStorageKeys.pendingRemoteSyncs);
      await store.markPending(PendingSyncDataset.subjects);

      // Already present, so no persist happened and storage stays untouched.
      expect(
        storage.data.containsKey(LocalStorageKeys.pendingRemoteSyncs),
        isFalse,
      );
    });
  });
}
