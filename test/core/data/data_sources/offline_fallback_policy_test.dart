import "dart:async";
import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/data_sources/friends_data_source.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_error_classifier.dart";

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

class _FailingSupabase implements SupabaseService {
  _FailingSupabase(this.error);

  final Object error;

  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient => throw error;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const PostgrestException _rejection = PostgrestException(
  message: "rejected",
  code: "42501",
);

GroupEntity _group() => const GroupEntity(
  id: "g1",
  name: "Grupo",
  theme: GroupThemeType.studying,
  members: [],
);

class _Env {
  _Env(Object error, {required bool reachable}) {
    supabase = _FailingSupabase(error);
    isBackendReachable = () => reachable;
  }

  final _MemStorage storage = _MemStorage();
  late final PendingSyncStore store = PendingSyncStore(
    localStorageService: storage,
  );
  late final SupabaseService supabase;
  late final bool Function() isBackendReachable;

  GroupsDataSource get groups => GroupsDataSource(
    supabaseService: supabase,
    logger: AppLoggerService(),
    localStorageService: storage,
    pendingSyncStore: store,
    isBackendReachable: isBackendReachable,
  );

  FriendsDataSource get friends => FriendsDataSource(
    supabaseService: supabase,
    logger: AppLoggerService(),
    localStorageService: storage,
    pendingSyncStore: store,
    isBackendReachable: isBackendReachable,
  );

  ActivityDataSource get activity => ActivityDataSource(
    supabaseService: supabase,
    localStorageService: storage,
    pendingSyncStore: store,
    logger: AppLoggerService(),
    isBackendReachable: isBackendReachable,
  );
}

void main() {
  group("shouldUseOfflineFallback", () {
    test("refuses a server rejection while the backend is reachable", () {
      expect(shouldUseOfflineFallback(_rejection), isFalse);
      expect(
        shouldUseOfflineFallback(_rejection, isBackendReachable: () => true),
        isFalse,
      );
    });

    test("allows a server rejection only when flagged offline", () {
      expect(
        shouldUseOfflineFallback(_rejection, isBackendReachable: () => false),
        isTrue,
      );
    });

    test("allows transport failures while reachable", () {
      expect(shouldUseOfflineFallback(TimeoutException("slow")), isTrue);
      expect(shouldUseOfflineFallback(StateError("offline")), isTrue);
      expect(
        shouldUseOfflineFallback(
          const PostgrestException(message: "unavailable", code: "503"),
        ),
        isTrue,
      );
    });
  });

  group("while the backend is reachable, a server rejection", () {
    test("is reported for leaveGroup instead of being queued", () async {
      final env = _Env(_rejection, reachable: true);
      env.storage.data[LocalStorageKeys.cachedGroups] = jsonEncode([
        _group().toMap(),
      ]);

      final result = await env.groups.leaveGroup("g1");

      expect(result.isLeft(), isTrue);
      expect(env.store.contains(PendingSyncDataset.groups), isFalse);
      final cached = env.storage.data[LocalStorageKeys.cachedGroups] as String;
      expect(jsonDecode(cached), hasLength(1));
    });

    test("is reported for updateGroup instead of being queued", () async {
      final env = _Env(_rejection, reachable: true);
      env.storage.data[LocalStorageKeys.cachedGroups] = jsonEncode([
        _group().toMap(),
      ]);

      final result = await env.groups.updateGroup(
        group: _group(),
        name: "Novo",
        description: "",
        activityPayload: const {},
      );

      expect(result.isLeft(), isTrue);
      expect(env.store.contains(PendingSyncDataset.groups), isFalse);
      final cached = env.storage.data[LocalStorageKeys.cachedGroups] as String;
      expect((jsonDecode(cached) as List).single["name"], "Grupo");
    });

    test("is reported by getGroups instead of serving the cache", () async {
      final env = _Env(_rejection, reachable: true);
      env.storage.data[LocalStorageKeys.cachedGroups] = jsonEncode([
        _group().toMap(),
      ]);

      expect((await env.groups.getGroups()).isLeft(), isTrue);
    });

    test("is reported for a friend request instead of being queued", () async {
      final env = _Env(_rejection, reachable: true);

      final result = await env.friends.sendFriendRequest("friend-2");

      expect(result.isLeft(), isTrue);
      expect(env.store.contains(PendingSyncDataset.friends), isFalse);
    });

    test("is reported by getSocial instead of serving the cache", () async {
      final env = _Env(_rejection, reachable: true);
      env.storage.data[LocalStorageKeys.cachedFriendsSocial] = jsonEncode(
        const FriendsSocialEntity.empty().toMap(),
      );

      expect((await env.friends.getSocial()).isLeft(), isTrue);
    });

    test("is reported for an activity row instead of being queued", () async {
      final env = _Env(_rejection, reachable: true);

      final result = await env.activity.logActivity(
        category: TimeCategoryType.studying,
        subjectId: "s1",
        subjectName: "Matemática",
        seconds: 60,
      );

      expect(result.isLeft(), isTrue);
      expect(env.store.contains(PendingSyncDataset.activityEntries), isFalse);
    });
  });

  group("while flagged offline, the same failure", () {
    test("is queued for leaveGroup", () async {
      final env = _Env(_rejection, reachable: false);

      final result = await env.groups.leaveGroup("g1");

      expect(result.isRight(), isTrue);
      expect(env.store.contains(PendingSyncDataset.groups), isTrue);
    });

    test("is queued for a friend request", () async {
      final env = _Env(_rejection, reachable: false);

      final result = await env.friends.sendFriendRequest("friend-2");

      expect(result.isRight(), isTrue);
      expect(env.store.contains(PendingSyncDataset.friends), isTrue);
    });

    test("is queued for an activity row", () async {
      final env = _Env(_rejection, reachable: false);

      final result = await env.activity.logActivity(
        category: TimeCategoryType.studying,
        subjectId: "s1",
        subjectName: "Matemática",
        seconds: 60,
      );

      expect(result.isRight(), isTrue);
      expect(env.store.contains(PendingSyncDataset.activityEntries), isTrue);
    });
  });

  group("a transport failure while reachable", () {
    test("still queues the write", () async {
      final env = _Env(TimeoutException("slow"), reachable: true);

      final result = await env.friends.sendFriendRequest("friend-2");

      expect(result.isRight(), isTrue);
      expect(env.store.contains(PendingSyncDataset.friends), isTrue);
    });
  });
}
