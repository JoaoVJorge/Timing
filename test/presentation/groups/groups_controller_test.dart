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
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_groups_use_case.dart";
import "package:timing/core/domain/use_cases/get_friends_social_use_case.dart";
import "package:timing/core/domain/use_cases/accept_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/cancel_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/remove_friend_use_case.dart";
import "package:timing/core/domain/use_cases/send_friend_request_use_case.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/groups/groups_page.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/theme.dart";

class _FakeDailyTasksRepository extends Fake implements DailyTasksRepository {}

class _FakeGroupsRepository implements GroupsRepository {
  _FakeGroupsRepository(this.groupsResult);

  List<GroupEntity> groupsResult;
  Completer<List<GroupEntity>>? groupsCompleter;
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

  @override
  Future<Either<AppError, List<GroupEntity>>> getGroups() async {
    getGroupsCalls++;
    final Completer<List<GroupEntity>>? completer = groupsCompleter;
    if (completer != null) {
      return Right(await completer.future);
    }
    return Right(groupsResult);
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
  _FakeFriendsRepository(this.friends);

  final List<FriendEntity> friends;
  final List<String> sentRequestIds = <String>[];
  final List<String> canceledRequestIds = <String>[];

  @override
  Future<Either<AppError, FriendsSocialEntity>> getSocial() async => Right(
    FriendsSocialEntity(
      inviteCode: "",
      requests: const [],
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

      expect(repository.getGroupsCalls, callsAfterInit);

      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();

      expect(repository.getGroupsCalls, callsAfterInit + 1);

      controller.onClose();
      bus.dispose();
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
        ["personal", "other-group"],
      );
      final List<dynamic> retainedActivities =
          jsonDecode(storage.values[LocalStorageKeys.subjects]! as String)
              as List<dynamic>;
      expect(
        retainedActivities.map((item) => (item as Map<String, dynamic>)["id"]),
        ["personal-activity", "other-group-activity"],
      );
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
    final Finder friendsDescription = find.byKey(
      const ValueKey("friends-card-description"),
    );
    expect(friendsDescription, findsOneWidget);
    expect(
      tester.getTopLeft(friendsDescription).dy,
      greaterThan(tester.getBottomLeft(friendsTitle).dy),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey("friends-card-avatar-ana")))
          .dy,
      greaterThan(tester.getBottomLeft(friendsDescription).dy),
    );
    expect(find.text("Descrição criada pelo usuário"), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets("blocks group content with an offline notice", (tester) async {
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
}

GroupsController _controller(
  _FakeGroupsRepository repository, {
  ActivityChangeBus? activityChangeBus,
  List<FriendEntity> friends = const [],
  _FakeFriendsRepository? friendsRepository,
  AppLocalStorageService? localStorageService,
  ConnectivityService? connectivityService,
}) {
  final _FakeFriendsRepository effectiveFriendsRepository =
      friendsRepository ?? _FakeFriendsRepository(friends);
  return GroupsController(
    getGroupsUseCase: GetGroupsUseCase(groupsRepository: repository),
    getFriendsSocialUseCase: GetFriendsSocialUseCase(
      friendsRepository: effectiveFriendsRepository,
    ),
    sendFriendRequestUseCase: SendFriendRequestUseCase(
      friendsRepository: effectiveFriendsRepository,
    ),
    cancelFriendRequestUseCase: CancelFriendRequestUseCase(
      friendsRepository: effectiveFriendsRepository,
    ),
    acceptFriendRequestUseCase: AcceptFriendRequestUseCase(
      friendsRepository: effectiveFriendsRepository,
    ),
    removeFriendUseCase: RemoveFriendUseCase(
      friendsRepository: effectiveFriendsRepository,
    ),
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
