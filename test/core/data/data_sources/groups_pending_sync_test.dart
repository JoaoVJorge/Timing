import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
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

GroupEntity _group({String id = "g1"}) => GroupEntity(
  id: id,
  name: "Grupo de estudos",
  theme: GroupThemeType.studying,
  members: const [],
);

Future<(GroupsDataSource, PendingSyncStore, _MemStorage)> _build() async {
  final storage = _MemStorage();
  final store = PendingSyncStore(localStorageService: storage);
  await store.load();
  final dataSource = GroupsDataSource(
    supabaseService: _OfflineSupabase(),
    logger: AppLoggerService(),
    localStorageService: storage,
    pendingSyncStore: store,
  );
  return (dataSource, store, storage);
}

void main() {
  group("GroupsDataSource offline sync", () {
    test("getGroups falls back to the cache when remote fails", () async {
      final (dataSource, _, storage) = await _build();
      storage.data[LocalStorageKeys.cachedGroups] = jsonEncode([
        _group().toMap(),
      ]);

      final result = await dataSource.getGroups();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail("expected Right"), (groups) {
        expect(groups, hasLength(1));
        expect(groups.single.id, "g1");
      });
    });

    test("getGroups errors when remote fails and there is no cache", () async {
      final (dataSource, _, _) = await _build();

      final result = await dataSource.getGroups();

      expect(result.isLeft(), isTrue);
    });

    test(
      "updateGroup applies the change optimistically and queues it",
      () async {
        final (dataSource, store, storage) = await _build();
        storage.data[LocalStorageKeys.cachedGroups] = jsonEncode([
          _group().toMap(),
        ]);

        final result = await dataSource.updateGroup(
          group: _group(),
          name: "Novo nome",
          description: "Nova descrição",
          activityPayload: const {},
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail("expected Right"), (group) {
          expect(group.name, "Novo nome");
        });
        expect(store.contains(PendingSyncDataset.groups), isTrue);
        final String cached = storage.data[LocalStorageKeys.cachedGroups] as String;
        final List<dynamic> decoded = jsonDecode(cached) as List<dynamic>;
        expect(decoded.single["name"], "Novo nome");
      },
    );

    test(
      "leaveGroup removes the group from cache and queues it",
      () async {
        final (dataSource, store, storage) = await _build();
        storage.data[LocalStorageKeys.cachedGroups] = jsonEncode([
          _group().toMap(),
        ]);

        final result = await dataSource.leaveGroup("g1");

        expect(result.isRight(), isTrue);
        expect(store.contains(PendingSyncDataset.groups), isTrue);
        final String cached = storage.data[LocalStorageKeys.cachedGroups] as String;
        expect(jsonDecode(cached), isEmpty);
      },
    );

    test("keeps the dataset pending while the retry still fails", () async {
      final (dataSource, store, _) = await _build();
      await dataSource.leaveGroup("g1");

      await dataSource.flushPendingSync();

      expect(store.contains(PendingSyncDataset.groups), isTrue);
    });
  });
}
