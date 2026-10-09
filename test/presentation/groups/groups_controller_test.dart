import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:fake_async/fake_async.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_image_messages_page.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/group_join_request_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/social/social_store.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/groups/groups_page.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/theme.dart";

class _FakeDailyTasksRepository extends Fake implements DailyTasksRepository {}

class _FakeGroupsRepository implements GroupsRepository {
  _FakeGroupsRepository(this.groupsResult);

  List<GroupEntity> groupsResult;
  List<GroupEntity> cachedGroups = const [];
  @override
  bool lastGroupsFetchServedCache = false;
  Completer<List<GroupEntity>>? groupsCompleter;
  // When set, call N (1-indexed) awaits getGroupsCallCompleters[N-1] instead
  // of the single shared groupsCompleter, so a test can control the
  // resolution order of multiple concurrent getGroups() calls independently.
  List<Completer<List<GroupEntity>>>? getGroupsCallCompleters;
  int getGroupsCalls = 0;
  final Map<String, List<GroupActivityProgressEntity>> progressByGroup =
      <String, List<GroupActivityProgressEntity>>{};
  final List<String> progressRequests = <String>[];
  GroupImageMessagesPage initialImagePage = const GroupImageMessagesPage(
    messages: [],
    hasMore: false,
  );
  final Completer<GroupImageMessageEntity> olderImageCursor =
      Completer<GroupImageMessageEntity>();
  final Completer<GroupImageMessagesPage> olderImagePage =
      Completer<GroupImageMessagesPage>();
  final List<String> leaveRequests = <String>[];
  final List<String> resetRequests = <String>[];
  List<GroupJoinRequestEntity> joinRequests = const [];
  final List<({String requestId, bool approve})> answeredJoinRequests =
      <({String requestId, bool approve})>[];

  @override
  Future<Either<AppError, List<GroupJoinRequestEntity>>> getJoinRequests(
    String groupId,
  ) async => Right(joinRequests);

  @override
  Future<Either<AppError, void>> answerJoinRequest({
    required String requestId,
    required bool approve,
  }) async {
    answeredJoinRequests.add((requestId: requestId, approve: approve));
    joinRequests = joinRequests
        .where((request) => request.id != requestId)
        .toList();
    return const Right(null);
  }

  int pendingInvitationCount = 0;

  @override
  Future<Either<AppError, List<GroupInvitationEntity>>>
  getPendingInvitations() async => Right([
    for (int index = 0; index < pendingInvitationCount; index++)
      GroupInvitationEntity(
        id: "invite-$index",
        groupId: "group-$index",
        groupName: "Grupo $index",
        theme: GroupThemeType.studying,
        inviterId: "ana",
        inviterName: "Ana",
      ),
  ]);

  @override
  Future<Either<AppError, List<GroupEntity>>> getGroups() async {
    getGroupsCalls++;
    final List<Completer<List<GroupEntity>>>? sequenced =
        getGroupsCallCompleters;
    if (sequenced != null && getGroupsCalls <= sequenced.length) {
      return Right(await sequenced[getGroupsCalls - 1].future);
    }
    final Completer<List<GroupEntity>>? completer = groupsCompleter;
    if (completer != null) {
      return Right(await completer.future);
    }
    return Right(groupsResult);
  }

  @override
  Future<Either<AppError, List<GroupEntity>>> getCachedGroups() async =>
      Right(cachedGroups);

  int refreshGroupScoresCalls = 0;
  bool scoresRefreshFails = false;

  @override
  Future<Either<AppError, List<GroupEntity>>> refreshGroupScores(
    List<GroupEntity> groups,
  ) async {
    refreshGroupScoresCalls++;
    if (scoresRefreshFails) {
      return const Left(
        UnexpectedError(cause: "down", stackTrace: StackTrace.empty),
      );
    }
    return Right(groups);
  }

  @override
  Future<Either<AppError, List<GroupActivityProgressEntity>>>
  getGroupActivityProgress(String groupId, {String? localDate}) async {
    progressRequests.add(groupId);
    return Right(progressByGroup[groupId] ?? const []);
  }

  @override
  Future<Either<AppError, GroupImageMessagesPage>> getImageMessages(
    String groupId, {
    GroupImageMessageEntity? before,
  }) async {
    if (before == null) {
      return Right(initialImagePage);
    }
    olderImageCursor.complete(before);
    return Right(await olderImagePage.future);
  }

  @override
  Future<Either<AppError, void>> leaveGroup(String groupId) async {
    leaveRequests.add(groupId);
    return const Right(null);
  }

  @override
  Future<Either<AppError, void>> resetGroupProgress(String groupId) async {
    resetRequests.add(groupId);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFriendsRepository implements FriendsRepository {
  _FakeFriendsRepository(this.friends, {this.requests = const []});

  final List<FriendEntity> friends;
  final List<FriendEntity> requests;
  final List<String> sentRequestIds = <String>[];
  final List<String> canceledRequestIds = <String>[];

  @override
  Future<Either<AppError, FriendsSocialEntity>> getSocial() async => Right(
    FriendsSocialEntity(
      inviteCode: "",
      requests: requests,
      sentRequests: const [],
      friends: friends,
    ),
  );

  @override
  Future<Either<AppError, void>> sendFriendRequest(String addresseeId) async {
    sentRequestIds.add(addresseeId);
    return const Right(null);
  }

  @override
  Future<Either<AppError, void>> cancelSentRequest({
    required String addresseeId,
    String friendshipId = "",
  }) async {
    canceledRequestIds.add(addresseeId);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseService implements SupabaseService {
  @override
  String? get currentUserId => "me";

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppNavigator implements AppNavigator {
  @override
  void showErrorSnackBar([String? text]) {}

  @override
  void showSuccessSnackBar(String text) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalStorageService implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object> values = <LocalStorageKeys, Object>{};
  final List<LocalStorageKeys> deletedKeys = <LocalStorageKeys>[];

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => values[key] as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    values[key] = value as Object;
  }

  @override
  Future<void> delete(LocalStorageKeys key) async {
    deletedKeys.add(key);
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  group("the social store shared with the friends screens", () {
    test("a friend made elsewhere is a friend on the member list at once", () {
      final SocialStore store = SocialStore(
        friendsRepository: _FakeFriendsRepository(const []),
      );
      final GroupsController controller = _controller(
        _FakeGroupsRepository(const []),
        socialStore: store,
      );
      expect(controller.isFriend("ana"), isFalse);

      store.friends.add(
        const FriendEntity(
          id: "ana",
          friendshipId: "friendship-1",
          name: "Ana",
          handle: "@ana",
          colorValue: 0,
        ),
      );

      expect(controller.isFriend("ana"), isTrue);
      expect(controller.friends, same(store.friends));
    });

    test("a group joined from another screen is added and selected", () async {
      final SocialStore store = SocialStore(
        friendsRepository: _FakeFriendsRepository(const []),
      );
      final GroupsController controller = _controller(
        _FakeGroupsRepository(const []),
        socialStore: store,
      );
      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      addTearDown(controller.onClose);
      final GroupEntity joined = _group("group-9", "Novo");

      store.announceJoinedGroup(joined);
      await Future<void>.delayed(Duration.zero);

      expect(controller.groups.map((group) => group.id), contains("group-9"));
      expect(controller.selectedGroup.value?.id, "group-9");
    });
  });

  group("GroupsController refreshAfterActivityChange", () {
    test(
      "keeps the affected group selected and reloads its goal status",
      () async {
        final GroupEntity firstGroup = _group("group-1", "Primeiro");
        final GroupEntity affectedGroup = _group("group-2", "Segundo");
        final _FakeGroupsRepository repository = _FakeGroupsRepository([
          firstGroup,
          affectedGroup,
        ]);
        repository.progressByGroup["group-2"] = const [
          GroupActivityProgressEntity(
            activityId: "activity-2",
            kind: "goal",
            name: "Beber agua",
            memberId: "me",
            progress: 1,
            target: 1,
            reached: true,
          ),
        ];
        final GroupsController controller = _controller(repository);
        await controller.loadGroups();
        controller.selectedGroup.value = affectedGroup;
        controller.selectedDetailsTab.value = GroupDetailsTab.goals;

        await controller.refreshAfterActivityChange(groupId: "group-2");

        expect(controller.selectedGroup.value?.id, "group-2");
        expect(repository.progressRequests, ["group-2"]);
        expect(controller.activityProgress.single.reached, true);
      },
    );
  });

  test("a burst of activity-change events coalesces into one refresh", () {
    fakeAsync((async) {
      final GroupEntity group = _group("group-1", "Primeiro");
      final _FakeGroupsRepository repository = _FakeGroupsRepository([group]);
      final ActivityChangeBus bus = ActivityChangeBus();
      final GroupsController controller = _controller(
        repository,
        activityChangeBus: bus,
      );

      controller.onInit();
      async.flushMicrotasks();
      final int callsAfterInit = repository.getGroupsCalls;

      bus.notifyGroupActivityChanged(groupId: "group-1");
      async.elapse(const Duration(seconds: 1));
      bus.notifyGroupActivityChanged(groupId: "group-1");
      async.elapse(const Duration(seconds: 1));
      bus.notifyGroupActivityChanged(groupId: "group-1");

      expect(repository.refreshGroupScoresCalls, 0);

      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();

      // One refresh of just the ranking; the groups themselves are not reread.
      expect(repository.refreshGroupScoresCalls, 1);
      expect(repository.getGroupsCalls, callsAfterInit);

      controller.onClose();
      bus.dispose();
    });
  });

  test("a failed scores refresh falls back to the full reload", () {
    fakeAsync((async) {
      final _FakeGroupsRepository repository = _FakeGroupsRepository([
        _group("group-1", "Primeiro"),
      ])..scoresRefreshFails = true;
      final GroupsController controller = _controller(repository);
      controller.onInit();
      async.flushMicrotasks();
      final int callsAfterInit = repository.getGroupsCalls;

      unawaited(controller.refreshAfterActivityChange(groupId: "group-1"));
      async.flushMicrotasks();

      expect(repository.refreshGroupScoresCalls, 1);
      expect(repository.getGroupsCalls, callsAfterInit + 1);
      controller.onClose();
    });
  });

  test("applies refreshed scores to the groups on screen", () async {
    final GroupEntity group = _group("group-1", "Primeiro");
    final _FakeGroupsRepository repository = _FakeGroupsRepository([group]);
    final GroupsController controller = _controller(repository);
    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    await controller.refreshAfterActivityChange(groupId: "group-1");

    expect(controller.groups.single.id, "group-1");
    expect(controller.selectedGroup.value?.id, "group-1");
    expect(repository.refreshGroupScoresCalls, 1);
    controller.onClose();
  });

  test("reloads fully when no groups have been loaded yet", () async {
    final _FakeGroupsRepository repository = _FakeGroupsRepository([
      _group("group-1", "Primeiro"),
    ]);
    final GroupsController controller = _controller(repository);

    await controller.refreshAfterActivityChange(groupId: "group-1");

    expect(repository.refreshGroupScoresCalls, 0);
    expect(repository.getGroupsCalls, 1);
    controller.onClose();
  });

  for (final bool hasPreferredGroup in [false, true]) {
    test(
      "reload preserves a newer selection (preferred: $hasPreferredGroup)",
      () async {
        final first = _group("group-1", "Primeiro");
        final second = _group("group-2", "Segundo");
        final updatedSecond = _group("group-2", "Segundo atualizado");
        final repository = _FakeGroupsRepository([first, second]);
        final controller = _controller(repository);
        await controller.loadGroups();

        final response = Completer<List<GroupEntity>>();
        repository.groupsCompleter = response;
        final reload = controller.loadGroups(
          preferredGroupId: hasPreferredGroup ? first.id : null,
        );
        controller.selectedGroup.value = second;
        response.complete([first, updatedSecond]);
        await reload;

        expect(controller.selectedGroup.value, same(updatedSecond));
        controller.onClose();
      },
    );
  }

  test(
    "activity refresh for another group preserves the visible group",
    () async {
      final first = _group("group-1", "Primeiro");
      final second = _group("group-2", "Segundo");
      final repository = _FakeGroupsRepository([first, second])
        ..scoresRefreshFails = true;
      final controller = _controller(repository);
      await controller.loadGroups();
      controller.selectedGroup.value = second;

      await controller.refreshAfterActivityChange(groupId: first.id);

      expect(repository.refreshGroupScoresCalls, 1);
      expect(repository.getGroupsCalls, 2);
      expect(controller.selectedGroup.value?.id, second.id);
      controller.onClose();
    },
  );

  test("automatic retry preserves selection made after a cached response", () {
    fakeAsync((async) {
      final first = _group("group-1", "Primeiro");
      final second = _group("group-2", "Segundo");
      final repository = _FakeGroupsRepository([first, second])
        ..lastGroupsFetchServedCache = true;
      final controller = _controller(repository);
      controller.selectedGroup.value = first;
      unawaited(controller.loadGroups());
      async.flushMicrotasks();
      controller.selectedGroup.value = second;

      repository.lastGroupsFetchServedCache = false;
      async.elapse(const Duration(seconds: 7));
      async.flushMicrotasks();

      expect(repository.getGroupsCalls, 2);
      expect(controller.selectedGroup.value?.id, second.id);
      controller.onClose();
    });
  });

  test("does not load groups offline and reloads after reconnecting", () async {
    final _FakeGroupsRepository repository = _FakeGroupsRepository(const []);
    final ConnectivityService connectivityService = ConnectivityService();
    connectivityService.isOnline.value = false;
    final GroupsController controller = _controller(
      repository,
      connectivityService: connectivityService,
    );

    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(repository.getGroupsCalls, 0);
    expect(controller.isLoading.value, isFalse);

    connectivityService.isOnline.value = true;
    await Future<void>.delayed(Duration.zero);

    expect(repository.getGroupsCalls, 1);
    controller.onClose();
  });

  test(
    "an older, slower loadGroups() call does not overwrite a newer one",
    () async {
      // Mirrors the real race: GroupsController's own connectivity listener
      // calls loadGroups() immediately on reconnect (call A, sees stale
      // server data because a queued edit hasn't been flushed yet), while
      // AppController's post-reconciliation reload calls loadGroups() again
      // right after the flush lands (call B, sees the synced data). Network
      // timing gives no guarantee call A resolves before call B.
      final GroupEntity staleGroup = _group("group-1", "Old Name");
      final GroupEntity freshGroup = _group("group-1", "New Name");
      final _FakeGroupsRepository repository = _FakeGroupsRepository(const []);
      final Completer<List<GroupEntity>> staleCompleter =
          Completer<List<GroupEntity>>();
      final Completer<List<GroupEntity>> freshCompleter =
          Completer<List<GroupEntity>>();
      repository.getGroupsCallCompleters = [staleCompleter, freshCompleter];
      final GroupsController controller = _controller(repository);

      final Future<void> callA = controller.loadGroups();
      final Future<void> callB = controller.loadGroups();

      freshCompleter.complete([freshGroup]);
      await callB;
      expect(controller.groups.single.name, "New Name");

      staleCompleter.complete([staleGroup]);
      await callA;

      expect(controller.groups.single.name, "New Name");

      controller.onClose();
    },
  );

  test(
    "leaving a group preserves personal and unrelated goals and activities",
    () async {
      final GroupEntity departingGroup = _group("group-1", "Saindo");
      final _FakeGroupsRepository repository = _FakeGroupsRepository([
        departingGroup,
      ]);
      final _FakeLocalStorageService storage = _FakeLocalStorageService();
      storage.values[LocalStorageKeys.dailyTasks] = jsonEncode([
        _dailyTask("personal").toMap(),
        _dailyTask("departing", groupId: "group-1").toMap(),
        _dailyTask("other-group", groupId: "group-2").toMap(),
      ]);
      storage.values[LocalStorageKeys.subjects] = jsonEncode([
        {"id": "personal-activity", "groupId": null},
        {"id": "departing-activity", "groupId": "group-1"},
        {"id": "other-group-activity", "groupId": "group-2"},
      ]);
      final GroupsController controller = _controller(
        repository,
        localStorageService: storage,
      );
      controller.groups.value = [departingGroup];
      controller.selectedGroup.value = departingGroup;

      await controller.onConfirmLeaveGroup();

      final List<dynamic> retainedGoals =
          jsonDecode(storage.values[LocalStorageKeys.dailyTasks]! as String)
              as List<dynamic>;
      expect(
        retainedGoals.map((item) => (item as Map<String, dynamic>)["id"]),
        ["personal", "departing", "other-group"],
      );
      final List<dynamic> retainedActivities =
          jsonDecode(storage.values[LocalStorageKeys.subjects]! as String)
              as List<dynamic>;
      expect(
        retainedActivities.map((item) => (item as Map<String, dynamic>)["id"]),
        ["personal-activity", "departing-activity", "other-group-activity"],
      );
      expect(retainedGoals[1]["groupId"], isNull);
      expect(retainedActivities[1]["groupId"], isNull);
      expect(storage.deletedKeys, isNot(contains(LocalStorageKeys.subjects)));
      expect(storage.deletedKeys, isNot(contains(LocalStorageKeys.dailyTasks)));
      expect(repository.leaveRequests, ["group-1"]);
    },
  );

  test("leaving a group preserves malformed activity caches", () async {
    final GroupEntity departingGroup = _group("group-1", "Saindo");
    final _FakeGroupsRepository repository = _FakeGroupsRepository([
      departingGroup,
    ]);
    final _FakeLocalStorageService storage = _FakeLocalStorageService();
    storage.values[LocalStorageKeys.dailyTasks] = "not-json";
    storage.values[LocalStorageKeys.subjects] = jsonEncode(["invalid-item"]);
    final GroupsController controller = _controller(
      repository,
      localStorageService: storage,
    );
    controller.groups.value = [departingGroup];
    controller.selectedGroup.value = departingGroup;

    await controller.onConfirmLeaveGroup();

    expect(storage.values[LocalStorageKeys.dailyTasks], "not-json");
    expect(
      storage.values[LocalStorageKeys.subjects],
      jsonEncode(["invalid-item"]),
    );
    expect(repository.leaveRequests, ["group-1"]);
  });

  test("only the owner can reset group progress", () async {
    final GroupEntity ownedGroup = _group("owned", "Meu grupo");
    final GroupEntity memberGroup = _group(
      "member",
      "Outro grupo",
      ownerId: "someone-else",
      memberRole: "member",
    );
    final GroupEntity staleRoleGroup = _group(
      "stale-role",
      "Papel local desatualizado",
      ownerId: "someone-else",
      memberRole: "owner",
    );
    final _FakeGroupsRepository repository = _FakeGroupsRepository([
      ownedGroup,
      memberGroup,
      staleRoleGroup,
    ]);
    final _FakeLocalStorageService storage = _FakeLocalStorageService();
    final GroupsController controller = _controller(
      repository,
      localStorageService: storage,
    );
    controller.groups.value = [ownedGroup, memberGroup];

    controller.selectedGroup.value = memberGroup;
    await controller.onConfirmResetGroup();
    expect(repository.resetRequests, isEmpty);

    controller.selectedGroup.value = staleRoleGroup;
    await controller.onConfirmResetGroup();
    expect(repository.resetRequests, isEmpty);

    controller.selectedGroup.value = ownedGroup;
    await controller.onConfirmResetGroup();
    expect(repository.resetRequests, ["owned"]);
    expect(storage.deletedKeys, isEmpty);
  });

  test("a retired role cannot reset group progress", () async {
    final GroupEntity viceGroup = _group(
      "vice",
      "Sou vice",
      ownerId: "someone-else",
      memberRole: "vice",
    );
    final _FakeGroupsRepository repository = _FakeGroupsRepository([viceGroup]);
    final GroupsController controller = _controller(repository);
    controller.groups.value = [viceGroup];
    controller.selectedGroup.value = viceGroup;

    expect(controller.isSelectedGroupOwner, isFalse);
    expect(controller.canManageSelectedGroup, isFalse);
    await controller.onConfirmResetGroup();

    expect(repository.resetRequests, isEmpty);
  });

  group("who may remove a member or change their role", () {
    GroupMemberEntity member(String id, String role) => GroupMemberEntity(
      id: id,
      name: id,
      avatarColorValue: 1,
      todaySeconds: 0,
      weekSeconds: 0,
      monthSeconds: 0,
      role: role,
    );
    GroupEntity groupWhereIAm(String role) => GroupEntity(
      id: "group-1",
      name: "Grupo",
      theme: GroupThemeType.dailyGoals,
      ownerId: role == GroupMemberEntity.ownerRole ? "me" : "leader",
      members: [
        member("me", role),
        if (role != GroupMemberEntity.ownerRole)
          member("leader", GroupMemberEntity.ownerRole),
        member("vice", "vice"),
        member("plain", GroupMemberEntity.memberRole),
      ],
    );
    Set<String> manageable(String role) {
      final GroupEntity group = groupWhereIAm(role);
      final GroupsController controller = _controller(
        _FakeGroupsRepository([group]),
      );
      return {
        for (final GroupMemberEntity other in group.members)
          if (controller.canManageMember(group, other)) other.id,
      };
    }

    test("the leader: everyone else", () {
      expect(manageable(GroupMemberEntity.ownerRole), {"vice", "plain"});
    });

    test("a retired role grants no management permissions", () {
      expect(manageable("vice"), isEmpty);
    });

    test("an ordinary member: nobody", () {
      expect(manageable(GroupMemberEntity.memberRole), isEmpty);
    });
  });

  test(
    "older image merge preserves a message added during the request",
    () async {
      final GroupImageMessageEntity boundary = _imageMessage(
        "boundary",
        DateTime.utc(2026, 8, 26, 12),
      );
      final GroupImageMessageEntity older = _imageMessage(
        "older",
        DateTime.utc(2026, 8, 26, 11),
      );
      final GroupImageMessageEntity sentDuringRequest = _imageMessage(
        "sent",
        DateTime.utc(2026, 8, 26, 13),
      );
      final _FakeGroupsRepository repository = _FakeGroupsRepository([])
        ..initialImagePage = GroupImageMessagesPage(
          messages: [boundary],
          hasMore: true,
        );
      final GroupsController controller = _controller(repository);
      await controller.loadImageMessages("group-1");

      final Future<void> loadingOlder = controller.loadOlderImageMessages(
        "group-1",
      );
      expect(await repository.olderImageCursor.future, boundary);
      expect(controller.isLoadingOlderImageMessagesFor("group-1"), isTrue);

      controller.imageMessagesByGroup["group-1"] = [
        boundary,
        sentDuringRequest,
      ];
      repository.olderImagePage.complete(
        GroupImageMessagesPage(messages: [older, boundary], hasMore: false),
      );
      await loadingOlder;

      expect(controller.isLoadingOlderImageMessagesFor("group-1"), isFalse);
      expect(
        controller.imageMessagesFor("group-1").map((message) => message.id),
        ["older", "boundary", "sent"],
      );
    },
  );

  test(
    "ranking cache preserves competition ranks and resets without a group",
    () {
      final GroupsController controller = _controller(
        _FakeGroupsRepository([]),
      );

      List<GroupMemberEntity> verifyRanking(
        List<int> scores,
        List<int> expectedRanks,
        List<int?> expectedDifferences,
      ) {
        final List<GroupMemberEntity> members = [
          for (final (int index, int score) in scores.indexed)
            _rankingMember("member-$index", score),
        ];
        controller.selectedGroup.value = GroupEntity(
          id: "ranking-${scores.join("-")}",
          name: "Ranking",
          theme: GroupThemeType.dailyGoals,
          members: members,
        );

        expect(
          controller.rankedMembers.map((member) => member.todaySeconds),
          scores,
        );
        expect(members.map(controller.rankOf), expectedRanks);
        expect(
          members.map(controller.differenceToPrevious),
          expectedDifferences,
        );
        return members;
      }

      verifyRanking([10, 10, 5], [1, 1, 3], [null, 0, 5]);
      final List<GroupMemberEntity> lastMembers = verifyRanking(
        [10, 8, 8, 5],
        [1, 2, 2, 4],
        [null, 2, 2, 3],
      );

      controller.selectedGroup.value = null;

      expect(controller.rankedMembers, isEmpty);
      expect(controller.rankOf(lastMembers.last), 1);
      expect(controller.differenceToPrevious(lastMembers.last), isNull);
    },
  );

  test("daily-goal ranking always uses total", () {
    final GroupsController controller = _controller(_FakeGroupsRepository([]));
    const GroupMemberEntity historicalLeader = GroupMemberEntity(
      id: "historical-leader",
      name: "Historical leader",
      avatarColorValue: 1,
      todaySeconds: 2,
      weekSeconds: 20,
      monthSeconds: 60,
      totalSeconds: 500,
    );
    const GroupMemberEntity dailyLeader = GroupMemberEntity(
      id: "daily-leader",
      name: "Daily leader",
      avatarColorValue: 2,
      todaySeconds: 10,
      weekSeconds: 15,
      monthSeconds: 40,
      totalSeconds: 200,
    );
    controller.selectedGroup.value = const GroupEntity(
      id: "period-ranking",
      name: "Period ranking",
      theme: GroupThemeType.dailyGoals,
      members: [historicalLeader, dailyLeader],
    );

    expect(controller.selectedPeriod.value, LeaderboardPeriodType.total);
    expect(controller.rankedMembers.first, historicalLeader);

    controller.onSelectPeriod(LeaderboardPeriodType.today);

    expect(controller.rankingPeriod, LeaderboardPeriodType.total);
    expect(controller.rankedMembers.first, historicalLeader);
    expect(controller.rankOf(historicalLeader), 1);
    expect(controller.rankOf(dailyLeader), 2);
  });

  test("non-goal ranking follows the selected period", () {
    final GroupsController controller = _controller(_FakeGroupsRepository([]));
    const GroupMemberEntity historicalLeader = GroupMemberEntity(
      id: "historical-leader",
      name: "Historical leader",
      avatarColorValue: 1,
      todaySeconds: 2,
      weekSeconds: 20,
      monthSeconds: 60,
      totalSeconds: 500,
    );
    const GroupMemberEntity dailyLeader = GroupMemberEntity(
      id: "daily-leader",
      name: "Daily leader",
      avatarColorValue: 2,
      todaySeconds: 10,
      weekSeconds: 15,
      monthSeconds: 40,
      totalSeconds: 200,
    );
    controller.selectedGroup.value = const GroupEntity(
      id: "period-ranking",
      name: "Period ranking",
      theme: GroupThemeType.studying,
      members: [historicalLeader, dailyLeader],
    );

    controller.onSelectPeriod(LeaderboardPeriodType.today);

    expect(controller.rankingPeriod, LeaderboardPeriodType.today);
    expect(controller.rankedMembers.first, dailyLeader);
    expect(controller.rankOf(dailyLeader), 1);
    expect(controller.rankOf(historicalLeader), 2);
  });

  test("current-user performance always uses the total ranking", () {
    final GroupsController controller = _controller(_FakeGroupsRepository([]));
    const GroupMemberEntity currentUser = GroupMemberEntity(
      id: "me",
      name: "Me",
      avatarColorValue: 1,
      todaySeconds: 10,
      weekSeconds: 10,
      monthSeconds: 10,
      totalSeconds: 20,
    );
    const GroupMemberEntity totalLeader = GroupMemberEntity(
      id: "total-leader",
      name: "Total leader",
      avatarColorValue: 2,
      todaySeconds: 1,
      weekSeconds: 1,
      monthSeconds: 1,
      totalSeconds: 50,
    );
    controller.selectedGroup.value = const GroupEntity(
      id: "performance-ranking",
      name: "Performance ranking",
      theme: GroupThemeType.studying,
      members: [currentUser, totalLeader],
    );
    controller.onSelectPeriod(LeaderboardPeriodType.today);

    expect(controller.rankedMembers.first, currentUser);
    expect(controller.currentUserRank, 2);
    expect(controller.memberAheadOfCurrentUser, totalLeader);
    expect(
      controller.differenceToPrevious(
        currentUser,
        period: LeaderboardPeriodType.total,
      ),
      30,
    );
  });

  testWidgets("group details tabs and member management render after split", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final GroupEntity group = _group(
      "group-1",
      "Grupo de teste",
      theme: GroupThemeType.studying,
    );
    final _FakeGroupsRepository repository = _FakeGroupsRepository([group]);
    final GroupsController controller = _controller(repository);
    controller.selectedGroup.value = group;
    controller.isShowingGroupDetails.value = true;
    Get.put<GroupsController>(controller);
    final AppLocalizations l10n = lookupAppLocalizations(const Locale("en"));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("en"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(showGroupFlowOnly: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text("Grupo de teste"), findsOneWidget);
    expect(find.text(l10n.leaderboardTitle), findsWidgets);
    expect(find.text(l10n.periodTotal), findsOneWidget);
    expect(tester.takeException(), isNull);

    final Finder periodFilterFinder = find.byKey(
      const ValueKey("leaderboard-period-filter"),
    );
    final PopupMenuButton<LeaderboardPeriodType> periodFilter = tester
        .widget<PopupMenuButton<LeaderboardPeriodType>>(periodFilterFinder);
    expect(periodFilter.menuPadding, EdgeInsets.zero);
    expect(periodFilter.clipBehavior, Clip.antiAlias);
    expect(periodFilter.position, PopupMenuPosition.under);

    await tester.tap(periodFilterFinder);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.periodToday), findsOneWidget);
    expect(find.text(l10n.periodThisWeek), findsOneWidget);
    expect(find.text(l10n.periodThisMonth), findsOneWidget);
    expect(find.text(l10n.periodTotal), findsNWidgets(2));
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    controller.onSelectPeriod(LeaderboardPeriodType.thisWeek);
    await tester.pump();
    expect(controller.selectedPeriod.value, LeaderboardPeriodType.thisWeek);

    controller.selectedGroup.value = _group(
      "goal-group",
      "Metas",
      theme: GroupThemeType.dailyGoals,
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey("leaderboard-period-filter")),
      findsNothing,
    );
    expect(controller.rankingPeriod, LeaderboardPeriodType.total);

    await tester.tap(find.text(l10n.goalsTabLabel).first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.selectedDetailsTab.value, GroupDetailsTab.goals);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(l10n.chatTabLabel).first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.selectedDetailsTab.value, GroupDetailsTab.chat);
    expect(tester.takeException(), isNull);

    controller.onManageMembers();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("Eu"), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  group("member management", () {
    GroupMemberEntity member(String id, String role) => GroupMemberEntity(
      id: id,
      name: id,
      avatarColorValue: 1,
      todaySeconds: 0,
      weekSeconds: 0,
      monthSeconds: 0,
      role: role,
    );

    late _FakeGroupsRepository lastRepository;
    Future<AppLocalizations> pumpMembers(
      WidgetTester tester, {
      required String myRole,
      List<GroupJoinRequestEntity> joinRequests = const [],
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final bool iLead = myRole == GroupMemberEntity.ownerRole;
      final GroupEntity group = GroupEntity(
        id: "group-1",
        name: "Grupo",
        theme: GroupThemeType.studying,
        ownerId: iLead ? "me" : "Lia",
        members: [
          member("me", myRole),
          if (!iLead) member("Lia", GroupMemberEntity.ownerRole),
          member("Vera", GroupMemberEntity.memberRole),
          member("Mario", GroupMemberEntity.memberRole),
        ],
      );
      final _FakeGroupsRepository repository = _FakeGroupsRepository([group])
        ..joinRequests = joinRequests;
      lastRepository = repository;
      final GroupsController controller = _controller(repository);
      controller.selectedGroup.value = group;
      controller.isShowingGroupDetails.value = true;
      // Opening the screen is also what reads who is waiting to be let in.
      controller.onManageMembers();
      Get.put<GroupsController>(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale("en"),
          theme: AppThemes.build(
            seed: Colors.blue,
            brightness: Brightness.light,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GroupsPage(showGroupFlowOnly: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      return lookupAppLocalizations(const Locale("en"));
    }

    /// Drags the row from the middle of the screen: once a row is pulled left
    /// its name is off screen and cannot be dragged by.
    Future<void> swipe(WidgetTester tester, String name, double dx) async {
      final double rowY = tester.getCenter(find.text(name)).dy;
      await tester.dragFrom(Offset(215, rowY), Offset(dx, 0));
      await tester.pumpAndSettle();
    }

    tearDown(Get.reset);

    testWidgets("all ordinary members share the same section", (tester) async {
      final AppLocalizations l10n = await pumpMembers(
        tester,
        myRole: GroupMemberEntity.ownerRole,
      );
      expect(find.text(l10n.groupMembersLabel), findsOneWidget);
      expect(find.text(l10n.groupMemberRoleLabel), findsNWidgets(2));
      expect(find.text("Vera"), findsOneWidget);
      expect(find.text("Mario"), findsOneWidget);
    });

    GroupJoinRequestEntity request(String id, {String? invitedByName}) =>
        GroupJoinRequestEntity(
          id: id,
          userId: id,
          userName: id,
          accentColorValue: 1,
          invitedById: invitedByName == null ? null : "someone",
          invitedByName: invitedByName,
        );

    testWidgets("the leader answers join requests at the top of the list", (
      tester,
    ) async {
      final AppLocalizations l10n = await pumpMembers(
        tester,
        myRole: GroupMemberEntity.ownerRole,
        joinRequests: [
          request("Ana", invitedByName: "Mario"),
          request("Beto"),
        ],
      );
      await tester.pump();

      expect(find.text(l10n.groupJoinRequestsTitle), findsOneWidget);
      expect(find.text(l10n.groupJoinRequestsCount(2)), findsOneWidget);
      expect(
        find.text(l10n.groupJoinRequestInvitedBy("Mario")),
        findsOneWidget,
      );
      expect(find.text(l10n.groupJoinRequestFromLink), findsOneWidget);
      // It sits above the member list, in place of the group summary.
      expect(
        tester.getTopLeft(find.text(l10n.groupJoinRequestsTitle)).dy,
        lessThan(tester.getTopLeft(find.text("Mario")).dy),
      );
      expect(find.text(l10n.groupParticipantsCount(4)), findsNothing);

      await tester.tap(find.byIcon(Icons.check_rounded).first);
      await tester.pumpAndSettle();
      expect(lastRepository.answeredJoinRequests, [
        (requestId: "Ana", approve: true),
      ]);

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(lastRepository.answeredJoinRequests.last, (
        requestId: "Beto",
        approve: false,
      ));
    });

    testWidgets("with nobody waiting the leader still sees the panel", (
      tester,
    ) async {
      final AppLocalizations l10n = await pumpMembers(
        tester,
        myRole: GroupMemberEntity.ownerRole,
      );
      await tester.pump();

      expect(find.text(l10n.groupJoinRequestsCount(0)), findsOneWidget);
      expect(find.text(l10n.groupJoinRequestsEmptyHint), findsOneWidget);
    });

    testWidgets("an ordinary member sees the group, not the requests", (
      tester,
    ) async {
      final AppLocalizations l10n = await pumpMembers(
        tester,
        myRole: GroupMemberEntity.memberRole,
        joinRequests: [request("Ana")],
      );
      await tester.pump();

      expect(find.text(l10n.groupJoinRequestsTitle), findsNothing);
      expect(find.text(l10n.groupParticipantsCount(4)), findsOneWidget);
    });

    testWidgets("the leader can transfer leadership and remove with an X", (
      tester,
    ) async {
      await pumpMembers(tester, myRole: GroupMemberEntity.ownerRole);
      await swipe(tester, "Vera", 300);
      expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_moderator_outlined), findsNothing);
      expect(find.byIcon(Icons.remove_moderator_outlined), findsNothing);
      await swipe(tester, "Vera", -600);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      final Container action = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.close_rounded),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((action.decoration! as BoxDecoration).color, Colors.transparent);
    });

    testWidgets("members and the leader reveal icons without backgrounds", (
      tester,
    ) async {
      await pumpMembers(tester, myRole: GroupMemberEntity.memberRole);
      for (final name in ["Mario", "Lia"]) {
        await swipe(tester, name, 300);
        // The "add member" button at the bottom shares this icon, so the
        // revealed one is the first in the tree.
        final Finder addFriend = find
            .byIcon(Icons.person_add_alt_1_rounded)
            .first;
        final Container action = tester.widget<Container>(
          find.ancestor(of: addFriend, matching: find.byType(Container)).first,
        );
        expect((action.decoration! as BoxDecoration).color, Colors.transparent);
        await swipe(tester, name, -600);
        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsNothing);
        await swipe(tester, name, 100);
      }
    });

    testWidgets("removing from the group and unfriending use different icons", (
      tester,
    ) async {
      await pumpMembers(tester, myRole: GroupMemberEntity.ownerRole);

      await swipe(tester, "Mario", -600);

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_remove_alt_1_rounded), findsNothing);
    });

    testWidgets("an ordinary member gets no management actions", (
      tester,
    ) async {
      final AppLocalizations l10n = await pumpMembers(
        tester,
        myRole: GroupMemberEntity.memberRole,
      );

      await swipe(tester, "Mario", 300);
      expect(find.byIcon(Icons.add_moderator_outlined), findsNothing);
      await swipe(tester, "Mario", -600);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      // Everyone may bring someone in; the leader answers what follows.
      expect(find.text(l10n.addMemberButton), findsOneWidget);
    });
  });

  group("goals tab activity data", () {
    Future<AppLocalizations> pumpGoalsTab(
      WidgetTester tester,
      GroupThemeType theme,
      GroupActivityProgressEntity activity,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final GroupEntity group = _group("group-1", "Grupo", theme: theme);
      final _FakeGroupsRepository repository = _FakeGroupsRepository([group])
        ..progressByGroup[group.id] = [activity];
      final GroupsController controller = _controller(repository);
      controller.selectedGroup.value = group;
      controller.isShowingGroupDetails.value = true;
      controller.selectedDetailsTab.value = GroupDetailsTab.goals;
      Get.put<GroupsController>(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale("en"),
          theme: AppThemes.build(
            seed: Colors.blue,
            brightness: Brightness.light,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GroupsPage(showGroupFlowOnly: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      return lookupAppLocalizations(const Locale("en"));
    }

    testWidgets("a reading group shows its page goal, not sessions", (
      tester,
    ) async {
      final AppLocalizations l10n = await pumpGoalsTab(
        tester,
        GroupThemeType.reading,
        const GroupActivityProgressEntity(
          activityId: "activity-1",
          kind: "subject",
          name: "Livro",
          memberId: "me",
          progress: 0,
          target: 10,
          reached: false,
        ),
      );

      expect(find.text(l10n.createSubjectPagesGoalLabel), findsOneWidget);
      expect(find.text(l10n.metricPagesValue(10)), findsWidgets);
      // Books have no focus time, pauses or sessions.
      expect(find.text(l10n.groupActivityFocusDataLabel), findsNothing);
      expect(find.text(l10n.groupActivityPauseDataLabel), findsNothing);
      expect(find.text(l10n.groupActivitySessionsDataLabel), findsNothing);
      expect(find.text(l10n.groupCompletedSessionsStatLabel), findsNothing);
      expect(find.text(l10n.groupGoalReachedStatLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("a study group keeps focus, pause and sessions", (
      tester,
    ) async {
      final AppLocalizations l10n = await pumpGoalsTab(
        tester,
        GroupThemeType.studying,
        const GroupActivityProgressEntity(
          activityId: "activity-1",
          kind: "subject",
          name: "Matéria",
          memberId: "me",
          progress: 0,
          target: 1800,
          reached: false,
          focusSeconds: 1800,
          restMinutes: 5,
          focusSessionCount: 3,
        ),
      );

      expect(find.text(l10n.groupActivityFocusDataLabel), findsOneWidget);
      expect(find.text(l10n.groupActivityPauseDataLabel), findsOneWidget);
      expect(find.text(l10n.groupActivitySessionsDataLabel), findsOneWidget);
      expect(find.text(l10n.groupCompletedSessionsStatLabel), findsOneWidget);
      expect(find.text(l10n.groupGoalReachedStatLabel), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets("groups home hides stale group count while loading", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final GroupEntity firstGroup = _group("group-1", "Primeiro");
    final GroupEntity staleSecondGroup = _group("group-2", "Segundo antigo");
    final GroupEntity freshGroup = _group("group-3", "Novo");
    final _FakeGroupsRepository repository = _FakeGroupsRepository([freshGroup])
      ..groupsCompleter = Completer<List<GroupEntity>>();
    final GroupsController controller = _controller(repository);
    controller.groups.assignAll([firstGroup, staleSecondGroup]);
    Get.put<GroupsController>(controller);
    final AppLocalizations l10n = lookupAppLocalizations(const Locale("en"));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("en"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(),
      ),
    );
    await tester.pump();

    expect(find.text(l10n.groupsFriendsSubtitleWithCount(2)), findsNothing);
    expect(find.byType(AppSkeleton), findsWidgets);

    repository.groupsCompleter!.complete([freshGroup]);
    await tester.pumpAndSettle();

    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.text(l10n.groupsFriendsSubtitleWithCount(1)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("friends card renders the current friends", (tester) async {
    final _FakeGroupsRepository repository = _FakeGroupsRepository([
      _group("group-1", "Grupo", description: "Descrição criada pelo usuário"),
    ]);
    final GroupsController controller = _controller(
      repository,
      friends: const [
        FriendEntity(
          id: "ana",
          friendshipId: "friendship-1",
          name: "Ana",
          handle: "ana",
          colorValue: 1,
        ),
        FriendEntity(
          id: "bia",
          friendshipId: "friendship-2",
          name: "Bia",
          handle: "bia",
          colorValue: 2,
        ),
      ],
    );
    Get.put<GroupsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("en"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey("friends-card-avatar-ana")),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey("friends-card-avatar-bia")),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey("friends-card-avatar-slot"))),
      tester.getTopLeft(find.byKey(const ValueKey("friends-card-avatar-ana"))),
    );
    final Finder friendsCard = find.byKey(const ValueKey("friends-card"));
    final Finder friendsTitle = find.descendant(
      of: friendsCard,
      matching: find.text(
        lookupAppLocalizations(const Locale("en")).groupsFriendsTitle,
      ),
    );
    // With friends to show, the avatars sit right under the title and the
    // descriptive text is gone.
    expect(
      find.byKey(const ValueKey("friends-card-description")),
      findsNothing,
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey("friends-card-avatar-ana")))
          .dy,
      greaterThan(tester.getBottomLeft(friendsTitle).dy),
    );
    expect(find.byKey(const ValueKey("friends-card-badge")), findsNothing);
    expect(find.text("Descrição criada pelo usuário"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group("friends card", () {
    const FriendEntity ana = FriendEntity(
      id: "ana",
      friendshipId: "friendship-1",
      name: "Ana",
      handle: "ana",
      colorValue: 1,
    );

    FriendEntity request(int index) => FriendEntity(
      id: "requester-$index",
      friendshipId: "request-$index",
      name: "Pessoa $index",
      handle: "pessoa$index",
      colorValue: 1,
    );

    Future<void> pumpGroupsHome(
      WidgetTester tester, {
      List<GroupEntity>? groups,
      List<FriendEntity> friends = const [],
      List<FriendEntity> requests = const [],
      int invitations = 0,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final _FakeGroupsRepository repository = _FakeGroupsRepository(
        groups ?? [_group("group-1", "Grupo")],
      )..pendingInvitationCount = invitations;
      final GroupsController controller = _controller(
        repository,
        friends: friends,
        incomingRequests: requests,
      );
      Get.put<GroupsController>(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale("en"),
          theme: AppThemes.build(
            seed: Colors.blue,
            brightness: Brightness.light,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GroupsPage(),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder badgeText(String text) => find.descendant(
      of: find.byKey(const ValueKey("friends-card-badge")),
      matching: find.text(text),
    );

    testWidgets("says what it is for only while there are no friends", (
      tester,
    ) async {
      await pumpGroupsHome(tester);

      final AppLocalizations l10n = lookupAppLocalizations(const Locale("en"));
      final Finder description = find.byKey(
        const ValueKey("friends-card-description"),
      );
      expect(description, findsOneWidget);
      expect(find.text(l10n.groupsFriendsSubtitleWithCount(1)), findsOneWidget);
      expect(
        tester.getTopLeft(description).dy,
        greaterThan(
          tester
              .getBottomLeft(
                find.descendant(
                  of: find.byKey(const ValueKey("friends-card")),
                  matching: find.text(l10n.groupsFriendsTitle),
                ),
              )
              .dy,
        ),
      );
    });

    testWidgets("has no circle when nothing is waiting for an answer", (
      tester,
    ) async {
      await pumpGroupsHome(tester, friends: const [ana]);

      expect(find.byKey(const ValueKey("friends-card-badge")), findsNothing);
    });

    testWidgets("counts friend requests and group invitations together", (
      tester,
    ) async {
      await pumpGroupsHome(
        tester,
        friends: const [ana],
        requests: [request(1), request(2)],
        invitations: 1,
      );

      expect(badgeText("3"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("counts a lone group invitation", (tester) async {
      await pumpGroupsHome(tester, invitations: 1);

      expect(badgeText("1"), findsOneWidget);
    });

    testWidgets("caps a very large count", (tester) async {
      await pumpGroupsHome(
        tester,
        requests: [for (int index = 0; index < 100; index++) request(index)],
        invitations: 5,
      );

      expect(badgeText("99+"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("still shows the circle and the friends with no groups yet", (
      tester,
    ) async {
      await pumpGroupsHome(
        tester,
        groups: const [],
        friends: const [ana],
        invitations: 2,
      );

      expect(badgeText("2"), findsOneWidget);
      expect(
        find.byKey(const ValueKey("friends-card-avatar-ana")),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey("friends-card-description")),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group("friends card loading skeleton", () {
    const FriendEntity ana = FriendEntity(
      id: "ana",
      friendshipId: "friendship-1",
      name: "Ana",
      handle: "ana",
      colorValue: 1,
    );

    Future<_FakeGroupsRepository> pumpLoadingHome(
      WidgetTester tester, {
      List<GroupEntity> staleGroups = const [],
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final _FakeGroupsRepository repository = _FakeGroupsRepository([
        _group("group-1", "Grupo"),
      ])..groupsCompleter = Completer<List<GroupEntity>>();
      final GroupsController controller = _controller(
        repository,
        friends: const [ana],
      );
      controller.groups.assignAll(staleGroups);
      Get.put<GroupsController>(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale("en"),
          theme: AppThemes.build(
            seed: Colors.blue,
            brightness: Brightness.light,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GroupsPage(),
        ),
      );
      await tester.pump();
      return repository;
    }

    /// Lets the load finish so no shimmer timer outlives the test.
    Future<void> finishLoading(
      WidgetTester tester,
      _FakeGroupsRepository repository,
    ) async {
      repository.groupsCompleter!.complete([_group("group-1", "Grupo")]);
      await tester.pumpAndSettle();
    }

    testWidgets("is one title bar over a row of friends, no line of text", (
      tester,
    ) async {
      final _FakeGroupsRepository repository = await pumpLoadingHome(tester);

      final Finder skeleton = find.byKey(
        const ValueKey("friends-card-skeleton"),
      );
      expect(skeleton, findsOneWidget);
      // The old card had a second bar for a line of text under the title.
      expect(
        find.descendant(of: skeleton, matching: find.byType(AppSkeletonBox)),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey("friends-card-skeleton-title")),
        findsOneWidget,
      );

      await finishLoading(tester, repository);
      expect(skeleton, findsNothing);
    });

    testWidgets("its title bar is one line of the real title tall", (
      tester,
    ) async {
      final _FakeGroupsRepository repository = await pumpLoadingHome(tester);

      final Finder titleBar = find.byKey(
        const ValueKey("friends-card-skeleton-title"),
      );
      final TextStyle titleStyle = tester
          .element(titleBar)
          .textStyles
          .cardTitle;
      expect(
        tester.getSize(titleBar).height,
        closeTo(titleStyle.fontSize! * titleStyle.height!, 0.01),
      );

      await finishLoading(tester, repository);
    });

    testWidgets("the card itself shows avatar circles while friends load", (
      tester,
    ) async {
      final _FakeGroupsRepository repository = await pumpLoadingHome(
        tester,
        staleGroups: [_group("group-1", "Antigo")],
      );

      final Finder slot = find.byKey(
        const ValueKey("friends-card-avatar-slot"),
      );
      expect(slot, findsOneWidget);
      expect(
        find.descendant(of: slot, matching: find.byType(AppSkeleton)),
        findsOneWidget,
      );
      // Not the old pill: nothing in the slot is a rounded bar.
      expect(
        find.descendant(of: slot, matching: find.byType(AppSkeletonBox)),
        findsNothing,
      );

      await finishLoading(tester, repository);
    });
  });

  test("the friends card count follows what the backend still holds", () async {
    final _FakeGroupsRepository repository = _FakeGroupsRepository(const [])
      ..pendingInvitationCount = 2;
    final GroupsController controller = _controller(
      repository,
      incomingRequests: [
        const FriendEntity(
          id: "requester",
          friendshipId: "request",
          name: "Pessoa",
          handle: "pessoa",
          colorValue: 1,
        ),
      ],
    );

    await controller.loadFriends();
    await controller.loadPendingGroupInvitationCount();

    expect(controller.pendingSocialCount, 3);

    // Answering an invitation elsewhere lowers the count on the next load.
    repository.pendingInvitationCount = 0;
    await controller.loadPendingGroupInvitationCount();

    expect(controller.pendingSocialCount, 1);
  });

  testWidgets("group cards grow with their descriptions", (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final GroupsController controller = _controller(
      _FakeGroupsRepository([
        _group("short", "Grupo curto", description: "Descrição curta."),
        _group(
          "long",
          "Grupo longo",
          description:
              "Uma descrição maior que ocupa várias linhas para que o cartão "
              "acompanhe naturalmente o conteúdo sem manter uma altura fixa.",
        ),
      ]),
    );
    Get.put<GroupsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("en"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(),
      ),
    );
    await tester.pumpAndSettle();

    final double shortHeight = tester
        .getSize(find.byKey(const ValueKey("group-card-short")))
        .height;
    final double longHeight = tester
        .getSize(find.byKey(const ValueKey("group-card-long")))
        .height;
    expect(longHeight, greaterThan(shortHeight));
    expect(tester.takeException(), isNull);
  });

  test("sends and cancels a friendship request from a group member", () async {
    final _FakeFriendsRepository friendsRepository = _FakeFriendsRepository(
      const [],
    );
    final GroupsController controller = _controller(
      _FakeGroupsRepository(const []),
      friendsRepository: friendsRepository,
    );
    const GroupMemberEntity member = GroupMemberEntity(
      id: "member-2",
      name: "Ana",
      avatarColorValue: 1,
      todaySeconds: 0,
      weekSeconds: 0,
      monthSeconds: 0,
    );

    await controller.onSendFriendRequestToMember(member);

    expect(friendsRepository.sentRequestIds, [member.id]);
    expect(controller.sentFriendRequestFor(member.id), isNotNull);

    await controller.onCancelFriendRequestToMember(member);

    expect(friendsRepository.canceledRequestIds, [member.id]);
    expect(controller.sentFriendRequestFor(member.id), isNull);
  });

  testWidgets("blocks the screen offline when no groups are saved", (
    tester,
  ) async {
    final ConnectivityService connectivityService = ConnectivityService();
    connectivityService.isOnline.value = false;
    final GroupsController controller = _controller(
      _FakeGroupsRepository([_group("group-1", "Grupo")]),
      connectivityService: connectivityService,
    );
    Get.put<GroupsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(),
      ),
    );
    await tester.pump();

    expect(find.text("Sem internet"), findsOneWidget);
    expect(
      find.text("Conecte-se à internet para acessar seus grupos."),
      findsOneWidget,
    );
    expect(find.text("Grupo"), findsNothing);
  });
  testWidgets("shows saved groups with a notice while offline", (tester) async {
    final ConnectivityService connectivityService = ConnectivityService();
    connectivityService.isOnline.value = false;
    final _FakeGroupsRepository repository = _FakeGroupsRepository(const [])
      ..cachedGroups = [_group("group-1", "Grupo salvo")];
    final GroupsController controller = _controller(
      repository,
      connectivityService: connectivityService,
    );
    Get.put<GroupsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text("Grupo salvo"), findsOneWidget);
    expect(
      find.text(
        "Você está offline. Mostrando seus grupos salvos; algumas ações "
        "precisam de conexão.",
      ),
      findsOneWidget,
    );
    expect(find.text("Sem internet"), findsNothing);
    expect(repository.getGroupsCalls, 0);
  });
  test(
    "flags stale groups when the saved copy was served while online",
    () async {
      final repository = _FakeGroupsRepository([_group("g1", "Grupo")])
        ..lastGroupsFetchServedCache = true;
      final controller = _controller(repository);

      await controller.loadGroups();

      expect(controller.isShowingStaleGroups.value, isTrue);
      controller.onClose();
    },
  );

  test("clears the stale flag once a refresh reaches the backend", () async {
    final repository = _FakeGroupsRepository([_group("g1", "Grupo")])
      ..lastGroupsFetchServedCache = true;
    final controller = _controller(repository);
    await controller.loadGroups();

    repository.lastGroupsFetchServedCache = false;
    await controller.loadGroups();

    expect(controller.isShowingStaleGroups.value, isFalse);
    controller.onClose();
  });

  test("retries a stale refresh on its own", () {
    fakeAsync((async) {
      final repository = _FakeGroupsRepository([_group("g1", "Grupo")])
        ..lastGroupsFetchServedCache = true;
      final controller = _controller(repository);
      unawaited(controller.loadGroups());
      async.flushMicrotasks();
      expect(repository.getGroupsCalls, 1);

      // The backend recovers before the automatic retry.
      repository.lastGroupsFetchServedCache = false;
      async.elapse(const Duration(seconds: 7));
      async.flushMicrotasks();

      expect(repository.getGroupsCalls, 2);
      expect(controller.isShowingStaleGroups.value, isFalse);
      controller.onClose();
    });
  });

  test("gives up automatic retries after a few stale attempts", () {
    fakeAsync((async) {
      final repository = _FakeGroupsRepository([_group("g1", "Grupo")])
        ..lastGroupsFetchServedCache = true;
      final controller = _controller(repository);
      unawaited(controller.loadGroups());
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 2));
      async.flushMicrotasks();

      // The first load plus two automatic retries.
      expect(repository.getGroupsCalls, 3);
      controller.onClose();
    });
  });

  testWidgets("shows a retry notice above stale groups", (tester) async {
    final repository = _FakeGroupsRepository([_group("g1", "Grupo salvo")])
      ..lastGroupsFetchServedCache = true;
    final controller = _controller(repository);
    Get.put<GroupsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GroupsPage(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text("Grupo salvo"), findsOneWidget);
    expect(
      find.text(
        "Não foi possível atualizar seus grupos. Mostrando os últimos dados "
        "salvos.",
      ),
      findsOneWidget,
    );

    repository.lastGroupsFetchServedCache = false;
    await tester.tap(find.text("Tentar novamente"));
    await tester.pump();
    await tester.pump();

    expect(controller.isShowingStaleGroups.value, isFalse);
    expect(
      find.text(
        "Não foi possível atualizar seus grupos. Mostrando os últimos dados "
        "salvos.",
      ),
      findsNothing,
    );
  });
}

GroupsController _controller(
  _FakeGroupsRepository repository, {
  ActivityChangeBus? activityChangeBus,
  List<FriendEntity> friends = const [],
  List<FriendEntity> incomingRequests = const [],
  _FakeFriendsRepository? friendsRepository,
  SocialStore? socialStore,
  AppLocalStorageService? localStorageService,
  ConnectivityService? connectivityService,
}) {
  final _FakeFriendsRepository effectiveFriendsRepository =
      friendsRepository ??
      _FakeFriendsRepository(friends, requests: incomingRequests);
  return GroupsController(
    socialStore:
        socialStore ??
        SocialStore(friendsRepository: effectiveFriendsRepository),
    groupsRepository: repository,
    dailyTasksRepository: _FakeDailyTasksRepository(),
    appNavigator: _FakeAppNavigator(),
    supabaseService: _FakeSupabaseService(),
    localStorageService: localStorageService ?? _FakeLocalStorageService(),
    activityChangeBus: activityChangeBus ?? ActivityChangeBus(),
    connectivityService: connectivityService,
  );
}

GroupEntity _group(
  String id,
  String name, {
  GroupThemeType theme = GroupThemeType.dailyGoals,
  String description = "",
  String ownerId = "me",
  String memberRole = "owner",
}) => GroupEntity(
  id: id,
  name: name,
  theme: theme,
  description: description,
  ownerId: ownerId,
  members: [
    GroupMemberEntity(
      id: "me",
      name: "Eu",
      avatarColorValue: 1,
      todaySeconds: 0,
      weekSeconds: 0,
      monthSeconds: 0,
      role: memberRole,
    ),
  ],
);

GroupMemberEntity _rankingMember(String id, int score) => GroupMemberEntity(
  id: id,
  name: id,
  avatarColorValue: 1,
  todaySeconds: score,
  weekSeconds: score,
  monthSeconds: score,
);

GroupImageMessageEntity _imageMessage(String id, DateTime createdAt) =>
    GroupImageMessageEntity(
      id: id,
      groupId: "group-1",
      senderId: "me",
      imageBase64: "image",
      createdAt: createdAt,
    );

DailyTaskEntity _dailyTask(String id, {String? groupId}) => DailyTaskEntity(
  id: id,
  name: id,
  colorValue: 1,
  targetDays: 1,
  completedDates: const [],
  groupId: groupId,
);
