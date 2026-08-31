import "dart:async";

import "package:dartz/dartz.dart";
import "package:fake_async/fake_async.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_image_messages_page.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_groups_use_case.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/groups/groups_page.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/theme.dart";

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalStorageService implements AppLocalStorageService {
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

  test("ranking changes with the selected period and defaults to total", () {
    final GroupsController controller = _controller(_FakeGroupsRepository([]));
    final GroupMemberEntity historicalLeader = GroupMemberEntity(
      id: "historical-leader",
      name: "Historical leader",
      avatarColorValue: 1,
      todaySeconds: 2,
      weekSeconds: 20,
      monthSeconds: 60,
      totalSeconds: 500,
    );
    final GroupMemberEntity dailyLeader = GroupMemberEntity(
      id: "daily-leader",
      name: "Daily leader",
      avatarColorValue: 2,
      todaySeconds: 10,
      weekSeconds: 15,
      monthSeconds: 40,
      totalSeconds: 200,
    );
    controller.selectedGroup.value = GroupEntity(
      id: "period-ranking",
      name: "Period ranking",
      theme: GroupThemeType.dailyGoals,
      members: [historicalLeader, dailyLeader],
    );

    expect(controller.selectedPeriod.value, LeaderboardPeriodType.total);
    expect(controller.rankedMembers.first, historicalLeader);

    controller.onSelectPeriod(LeaderboardPeriodType.today);

    expect(controller.rankedMembers.first, dailyLeader);
    expect(controller.rankOf(dailyLeader), 1);
    expect(controller.rankOf(historicalLeader), 2);
  });

  testWidgets("group details tabs and member management render after split", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final GroupEntity group = _group("group-1", "Grupo de teste");
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
    expect(find.byType(AppSkeleton), findsOneWidget);

    repository.groupsCompleter!.complete([freshGroup]);
    await tester.pumpAndSettle();

    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.text(l10n.groupsFriendsSubtitleWithCount(1)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

GroupsController _controller(
  _FakeGroupsRepository repository, {
  ActivityChangeBus? activityChangeBus,
}) => GroupsController(
  getGroupsUseCase: GetGroupsUseCase(groupsRepository: repository),
  groupsRepository: repository,
  appNavigator: _FakeAppNavigator(),
  supabaseService: _FakeSupabaseService(),
  localStorageService: _FakeLocalStorageService(),
  activityChangeBus: activityChangeBus ?? ActivityChangeBus(),
);

GroupEntity _group(String id, String name) => GroupEntity(
  id: id,
  name: name,
  theme: GroupThemeType.dailyGoals,
  members: const [
    GroupMemberEntity(
      id: "me",
      name: "Eu",
      avatarColorValue: 1,
      todaySeconds: 0,
      weekSeconds: 0,
      monthSeconds: 0,
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
