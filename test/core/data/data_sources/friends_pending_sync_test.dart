import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/friends_data_source.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
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

/// Backend that is reachable but rejects every write, like a duplicate row.
class _RejectingSupabase implements SupabaseService {
  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient =>
      throw const PostgrestException(message: "duplicate", code: "23505");

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

FriendEntity _friend({
  String id = "friend-1",
  String friendshipId = "fs-1",
}) => FriendEntity(
  id: id,
  friendshipId: friendshipId,
  name: "Amigo",
  handle: "@amigo",
  colorValue: 0xFF000000,
);

Future<(FriendsDataSource, PendingSyncStore, _MemStorage)> _build() async {
  final storage = _MemStorage();
  final store = PendingSyncStore(localStorageService: storage);
  await store.load();
  final dataSource = FriendsDataSource(
    supabaseService: _OfflineSupabase(),
    logger: AppLoggerService(),
    localStorageService: storage,
    pendingSyncStore: store,
  );
  return (dataSource, store, storage);
}

void main() {
  group("FriendsDataSource offline sync", () {
    test("getSocial falls back to the cache when remote fails", () async {
      final (dataSource, _, storage) = await _build();
      final cached = FriendsSocialEntity(
        inviteCode: "ABC123",
        requests: const [],
        sentRequests: const [],
        friends: [_friend()],
      );
      storage.data[LocalStorageKeys.cachedFriendsSocial] = jsonEncode(
        cached.toMap(),
      );

      final result = await dataSource.getSocial();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail("expected Right"), (social) {
        expect(social.friends, hasLength(1));
        expect(social.friends.single.id, "friend-1");
      });
    });

    test("getSocial errors when remote fails and there is no cache", () async {
      final (dataSource, _, _) = await _build();

      final result = await dataSource.getSocial();

      expect(result.isLeft(), isTrue);
    });

    test("sendFriendRequest queues on failure", () async {
      final (dataSource, store, _) = await _build();

      final result = await dataSource.sendFriendRequest("friend-2");

      expect(result.isRight(), isTrue);
      expect(store.contains(PendingSyncDataset.friends), isTrue);
    });

    test(
      "acceptRequest moves the entry from requests to friends in cache",
      () async {
        final (dataSource, store, storage) = await _build();
        final cached = FriendsSocialEntity(
          inviteCode: "ABC123",
          requests: [_friend()],
          sentRequests: const [],
          friends: const [],
        );
        storage.data[LocalStorageKeys.cachedFriendsSocial] = jsonEncode(
          cached.toMap(),
        );

        final result = await dataSource.acceptRequest("fs-1");

        expect(result.isRight(), isTrue);
        expect(store.contains(PendingSyncDataset.friends), isTrue);
        final String saved =
            storage.data[LocalStorageKeys.cachedFriendsSocial] as String;
        final updated = FriendsSocialEntity.fromMap(
          jsonDecode(saved) as Map<String, dynamic>,
        );
        expect(updated.requests, isEmpty);
        expect(updated.friends, hasLength(1));
      },
    );

    test("removeFriend removes the entry from the cache", () async {
      final (dataSource, store, storage) = await _build();
      final cached = FriendsSocialEntity(
        inviteCode: "ABC123",
        requests: const [],
        sentRequests: const [],
        friends: [_friend()],
      );
      storage.data[LocalStorageKeys.cachedFriendsSocial] = jsonEncode(
        cached.toMap(),
      );

      final result = await dataSource.removeFriend(
        friendId: "friend-1",
        friendshipId: "fs-1",
      );

      expect(result.isRight(), isTrue);
      expect(store.contains(PendingSyncDataset.friends), isTrue);
      final String saved =
          storage.data[LocalStorageKeys.cachedFriendsSocial] as String;
      final updated = FriendsSocialEntity.fromMap(
        jsonDecode(saved) as Map<String, dynamic>,
      );
      expect(updated.friends, isEmpty);
    });

    test("keeps the dataset pending while the retry still fails", () async {
      final (dataSource, store, _) = await _build();
      await dataSource.sendFriendRequest("friend-2");

      await dataSource.flushPendingSync();

      expect(store.contains(PendingSyncDataset.friends), isTrue);
    });

    test(
      "drops an action the server permanently rejects instead of blocking "
      "the queue",
      () async {
        final (offlineSource, store, storage) = await _build();
        await offlineSource.sendFriendRequest("friend-2");
        await offlineSource.sendFriendRequest("friend-3");
        expect(store.contains(PendingSyncDataset.friends), isTrue);

        final rejecting = FriendsDataSource(
          supabaseService: _RejectingSupabase(),
          logger: AppLoggerService(),
          localStorageService: storage,
          pendingSyncStore: store,
        );
        await rejecting.flushPendingSync();

        expect(store.contains(PendingSyncDataset.friends), isFalse);
        final String queue =
            storage.data[LocalStorageKeys.pendingFriendActions] as String;
        expect(jsonDecode(queue), isEmpty);
      },
    );
  });
}
