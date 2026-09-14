import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
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
import "package:timing/core/domain/use_cases/cancel_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/accept_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/send_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/remove_friend_use_case.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/main_tab_refresh_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/category/category_controller.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/shared/widgets/app_confirmation_dialog.dart";
import "package:timing/shared/widgets/photo_source_bottom_sheet.dart";
import "package:image_picker/image_picker.dart";

enum GroupDetailsTab { ranking, goals, chat }

class GroupsController extends GetxController {
  GroupsController({
    required this._getGroupsUseCase,
    required this._getFriendsSocialUseCase,
    required this._sendFriendRequestUseCase,
    required this._cancelFriendRequestUseCase,
    required this._acceptFriendRequestUseCase,
    required this._removeFriendUseCase,
    required this._groupsRepository,
    required this._appNavigator,
    required this._supabaseService,
    required this._localStorageService,
    required this._activityChangeBus,
    MainTabRefreshService? mainTabRefreshService,
  }) : _mainTabRefreshService =
           mainTabRefreshService ?? MainTabRefreshService();

  final GetGroupsUseCase _getGroupsUseCase;
  final GetFriendsSocialUseCase _getFriendsSocialUseCase;
  final SendFriendRequestUseCase _sendFriendRequestUseCase;
  final CancelFriendRequestUseCase _cancelFriendRequestUseCase;
  final AcceptFriendRequestUseCase _acceptFriendRequestUseCase;
  final RemoveFriendUseCase _removeFriendUseCase;
  final GroupsRepository _groupsRepository;
  final AppNavigator _appNavigator;
  final SupabaseService _supabaseService;
  final AppLocalStorageService _localStorageService;
  final ActivityChangeBus _activityChangeBus;
  final MainTabRefreshService _mainTabRefreshService;
  final ImagePicker _imagePicker = ImagePicker();

  /// A logged focus session auto-saves every few seconds; without a debounce
  /// each save would trigger a full groups refetch. Coalesce bursts into one
  /// refresh once the activity settles.
  static const Duration _activityChangeDebounce = Duration(seconds: 3);
  StreamSubscription<GroupActivityChange>? _activityChangeSubscription;
  Timer? _activityChangeDebounceTimer;
  String? _pendingActivityChangeGroupId;

  final RxList<GroupEntity> groups = <GroupEntity>[].obs;
  final RxList<FriendEntity> friends = <FriendEntity>[].obs;
  final RxList<FriendEntity> incomingFriendRequests = <FriendEntity>[].obs;
  final RxList<FriendEntity> sentFriendRequests = <FriendEntity>[].obs;
  final RxSet<String> updatingFriendshipMemberIds = <String>{}.obs;
  final RxSet<String> updatingGroupMemberIds = <String>{}.obs;
  final Rx<GroupEntity?> selectedGroup = Rx<GroupEntity?>(null);
  final Rx<LeaderboardPeriodType> selectedPeriod =
      LeaderboardPeriodType.total.obs;
  final Rx<GroupDetailsTab> selectedDetailsTab = GroupDetailsTab.ranking.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingFriends = true.obs;
  final RxBool isShowingGroupDetails = false.obs;
  final RxBool isShowingMemberManagement = false.obs;
  final RxBool isLoadingActivityProgress = false.obs;
  final RxBool isLoadingChat = false.obs;
  final RxBool isSendingImage = false.obs;
  final RxBool isResettingGroup = false.obs;
  final RxBool didFailLoadingGroups = false.obs;
  final RxMap<String, List<GroupImageMessageEntity>> imageMessagesByGroup =
      <String, List<GroupImageMessageEntity>>{}.obs;
  final RxList<GroupActivityProgressEntity> activityProgress =
      <GroupActivityProgressEntity>[].obs;

  String get currentUserId => _supabaseService.currentUserId ?? "";

  bool get isSelectedGroupOwner {
    final GroupEntity? group = selectedGroup.value;
    return group != null && isGroupOwner(group);
  }

  bool isGroupOwner(GroupEntity group) {
    final String userId = currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    return group.ownerId == userId;
  }

  /// Sorting the members is cheap on its own, but the ranking tab reads this
  /// getter (directly and through `rankOf`/`differenceToPrevious`) dozens of
  /// times per rebuild, so the sorted list is cached until the selected group
  /// or period changes. `selectedGroup.value` is always reassigned on a change,
  /// so an identity check is enough to invalidate.
  GroupEntity? _rankedCacheGroup;
  LeaderboardPeriodType? _rankedCachePeriod;
  List<GroupMemberEntity> _rankedCache = const [];
  Map<String, int> _rankByMemberId = const {};
  Map<String, int?> _differenceByMemberId = const {};
  Map<int, int> _memberCountByScore = const {};
  String? _activityProgressCacheKey;
  final Set<String> _loadingActivityProgressKeys = <String>{};
  final Map<String, List<GroupActivityProgressEntity>>
  _activityProgressByCacheKey = <String, List<GroupActivityProgressEntity>>{};
  final Set<String> _loadingImageMessageGroupIds = <String>{};
  final RxSet<String> _loadingOlderImageMessageGroupIds = <String>{}.obs;
  final Map<String, bool> _hasMoreImageMessagesByGroup = <String, bool>{};
  static const Duration _groupsLoadTimeout = Duration(seconds: 20);
  bool _hasLoadedGroups = false;

  /// Daily-goal groups are cumulative challenges, so their leaderboard never
  /// follows the date filter used by the other group themes.
  LeaderboardPeriodType get rankingPeriod =>
      selectedGroup.value?.theme == GroupThemeType.dailyGoals
      ? LeaderboardPeriodType.total
      : selectedPeriod.value;

  List<GroupMemberEntity> get rankedMembers {
    final GroupEntity? group = selectedGroup.value;
    final LeaderboardPeriodType period = rankingPeriod;
    if (group == null) {
      _clearRankingCaches();
      return const [];
    }
    if (identical(group, _rankedCacheGroup) && period == _rankedCachePeriod) {
      return _rankedCache;
    }
    final List<GroupMemberEntity> members = List.of(group.members)
      ..sort((a, b) => b.secondsFor(period).compareTo(a.secondsFor(period)));
    _rankedCacheGroup = group;
    _rankedCachePeriod = period;
    _rankedCache = members;
    _buildRankingCaches(members, period);
    return members;
  }

  void _clearRankingCaches() {
    _rankedCacheGroup = null;
    _rankedCachePeriod = null;
    _rankedCache = const [];
    _rankByMemberId = const {};
    _differenceByMemberId = const {};
    _memberCountByScore = const {};
  }

  void _buildRankingCaches(
    List<GroupMemberEntity> members,
    LeaderboardPeriodType period,
  ) {
    final Map<String, int> ranks = {};
    final Map<String, int?> differences = {};
    final Map<int, int> scoreCounts = {};
    int rank = 1;
    int? previousScore;
    int? higherScore;

    for (int index = 0; index < members.length; index++) {
      final GroupMemberEntity member = members[index];
      final int score = member.secondsFor(period);
      if (previousScore != null && score < previousScore) {
        rank = index + 1;
        higherScore = previousScore;
      }
      ranks[member.id] = rank;
      differences[member.id] = index == 0
          ? null
          : higherScore == null
          ? 0
          : higherScore - score;
      scoreCounts.update(score, (count) => count + 1, ifAbsent: () => 1);
      previousScore = score;
    }

    _rankByMemberId = ranks;
    _differenceByMemberId = differences;
    _memberCountByScore = scoreCounts;
  }

  GroupMemberEntity? get currentUserMember {
    for (final GroupMemberEntity member in rankedMembers) {
      if (isCurrentUser(member)) {
        return member;
      }
    }
    return null;
  }

  int get currentUserRank {
    final GroupMemberEntity? member = currentUserMember;
    return member == null
        ? 0
        : rankOf(member, period: LeaderboardPeriodType.total);
  }

  int rankOf(GroupMemberEntity member, {LeaderboardPeriodType? period}) {
    final LeaderboardPeriodType effectivePeriod = period ?? rankingPeriod;
    // Reading the getter refreshes every derived ranking cache when the group
    // or selected period changed.
    if (effectivePeriod == rankingPeriod) {
      rankedMembers;
      final int? cachedRank = _rankByMemberId[member.id];
      if (cachedRank != null) {
        return cachedRank;
      }
    }
    final int value = member.secondsFor(effectivePeriod);
    return _rankedMembersFor(
          effectivePeriod,
        ).where((item) => item.secondsFor(effectivePeriod) > value).length +
        1;
  }

  bool get currentUserIsTiedForFirst {
    final GroupMemberEntity? member = currentUserMember;
    if (member == null ||
        rankOf(member, period: LeaderboardPeriodType.total) != 1) {
      return false;
    }
    final int value = member.totalSeconds;
    if (rankingPeriod == LeaderboardPeriodType.total) {
      rankedMembers;
      return (_memberCountByScore[value] ?? 0) > 1;
    }
    return _rankedMembersFor(
          LeaderboardPeriodType.total,
        ).where((item) => item.totalSeconds == value).length >
        1;
  }

  /// Member ranked immediately above the current user, used to turn "2nd place"
  /// into a concrete target.
  GroupMemberEntity? get memberAheadOfCurrentUser {
    const LeaderboardPeriodType period = LeaderboardPeriodType.total;
    final List<GroupMemberEntity> members = _rankedMembersFor(period);
    final int index = members.indexWhere(isCurrentUser);
    if (index <= 0) {
      return null;
    }
    final int currentValue = members[index].secondsFor(period);
    for (int i = index - 1; i >= 0; i--) {
      if (members[i].secondsFor(period) > currentValue) {
        return members[i];
      }
    }
    return null;
  }

  int? differenceToPrevious(
    GroupMemberEntity member, {
    LeaderboardPeriodType? period,
  }) {
    final LeaderboardPeriodType effectivePeriod = period ?? rankingPeriod;
    // Keep this lookup in sync with the same lazy cache used by rankOf.
    if (effectivePeriod == rankingPeriod) {
      rankedMembers;
      if (_differenceByMemberId.containsKey(member.id)) {
        return _differenceByMemberId[member.id];
      }
    }
    final List<GroupMemberEntity> members = _rankedMembersFor(effectivePeriod);
    final int index = members.indexWhere((item) => item.id == member.id);
    if (index <= 0) {
      return null;
    }
    final int value = member.secondsFor(effectivePeriod);
    GroupMemberEntity? previous;
    for (int i = index - 1; i >= 0; i--) {
      if (members[i].secondsFor(effectivePeriod) > value) {
        previous = members[i];
        break;
      }
    }
    if (previous == null) {
      return 0;
    }
    return previous.secondsFor(effectivePeriod) - value;
  }

  List<GroupMemberEntity> _rankedMembersFor(LeaderboardPeriodType period) {
    if (period == rankingPeriod) {
      return rankedMembers;
    }
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return const [];
    }
    return List<GroupMemberEntity>.of(group.members)
      ..sort((a, b) => b.secondsFor(period).compareTo(a.secondsFor(period)));
  }

  bool isCurrentUser(GroupMemberEntity member) => member.id == currentUserId;

  bool isFriend(String memberId) =>
      friends.any((friend) => friend.id == memberId);

  bool hasIncomingFriendRequest(String memberId) =>
      incomingFriendRequests.any((request) => request.id == memberId);

  FriendEntity? sentFriendRequestFor(String memberId) =>
      sentFriendRequests.firstWhereOrNull((request) => request.id == memberId);

  @override
  void onInit() {
    super.onInit();
    _activityChangeSubscription = _activityChangeBus.stream.listen(
      _onGroupActivityChanged,
    );
    loadGroups();
    unawaited(loadFriends());
  }

  Future<void> loadFriends() async {
    isLoadingFriends.value = true;
    try {
      final Either<AppError, FriendsSocialEntity> result =
          await _getFriendsSocialUseCase();
      result.fold((_) {}, (social) {
        friends.assignAll(social.friends);
        incomingFriendRequests.assignAll(social.requests);
        sentFriendRequests.assignAll(social.sentRequests);
      });
    } finally {
      isLoadingFriends.value = false;
    }
  }

  @override
  void onClose() {
    _activityChangeDebounceTimer?.cancel();
    unawaited(_activityChangeSubscription?.cancel());
    super.onClose();
  }

  void _onGroupActivityChanged(GroupActivityChange change) {
    _pendingActivityChangeGroupId =
        change.groupId ?? _pendingActivityChangeGroupId;
    _activityChangeDebounceTimer?.cancel();
    _activityChangeDebounceTimer = Timer(_activityChangeDebounce, () {
      final String? groupId = _pendingActivityChangeGroupId;
      _pendingActivityChangeGroupId = null;
      unawaited(refreshAfterActivityChange(groupId: groupId));
    });
  }

  Future<void> loadGroups({String? preferredGroupId}) async {
    final String? selectedGroupId = preferredGroupId ?? selectedGroup.value?.id;
    bool membershipChanged = false;
    isLoading.value = true;
    didFailLoadingGroups.value = false;
    try {
      final Either<AppError, List<GroupEntity>> result =
          await _getGroupsUseCase().timeout(_groupsLoadTimeout);
      result.fold(
        (error) {
          didFailLoadingGroups.value = true;
          _appNavigator.showErrorSnackBar(error.message);
        },
        (value) {
          didFailLoadingGroups.value = false;
          final Set<String> previousGroupIds = groups
              .map((item) => item.id)
              .toSet();
          final Set<String> loadedGroupIds = value
              .map((item) => item.id)
              .toSet();
          if (_hasLoadedGroups &&
              (previousGroupIds.length != loadedGroupIds.length ||
                  !previousGroupIds.containsAll(loadedGroupIds))) {
            membershipChanged = true;
            _mainTabRefreshService.markGroupsChanged();
          }
          // Copy so the controller's list doesn't alias the data source's mutable
          // store — otherwise a created group appears in both the store add and the
          // controller add below, showing up twice.
          groups.value = List.of(value);
          selectedGroup.value = _preferredGroup(value, selectedGroupId);
          _hasLoadedGroups = true;
        },
      );
      if (membershipChanged) {
        await _invalidateActivityCaches();
      }
    } on TimeoutException {
      didFailLoadingGroups.value = true;
      _appNavigator.showErrorSnackBar();
    } finally {
      isLoading.value = false;
    }
  }

  GroupEntity? _preferredGroup(List<GroupEntity> value, String? groupId) {
    if (value.isEmpty) {
      return null;
    }
    if (groupId == null || groupId.isEmpty) {
      return value.first;
    }
    return value.firstWhereOrNull((group) => group.id == groupId) ??
        value.first;
  }

  void onSelectGroup(GroupEntity group) {
    selectedGroup.value = group;
    activityProgress.clear();
    _activityProgressCacheKey = null;
    isLoadingActivityProgress.value = false;
    selectedDetailsTab.value = GroupDetailsTab.ranking;
    isShowingGroupDetails.value = true;
    isShowingMemberManagement.value = false;
    unawaited(loadActivityProgress());
    _appNavigator.toNamed(AppRoutes.groupDetails);
  }

  /// Per-member completion of the selected group's activities, used by the
  /// group's "Metas" tab to show who completed it today.
  Future<void> loadActivityProgress() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      activityProgress.clear();
      _activityProgressCacheKey = null;
      return;
    }
    final String cacheKey = "${group.id}:${_todayKey()}";
    final List<GroupActivityProgressEntity>? cachedProgress =
        _activityProgressByCacheKey[cacheKey];
    if (cachedProgress != null) {
      // Copy so the observable's backing list never aliases the cached
      // instance — RxList.value assigns by reference, so a later
      // activityProgress.clear() (e.g. from onSelectGroup) would otherwise
      // empty the cached list too and poison every future read.
      activityProgress.value = List.of(cachedProgress);
      _activityProgressCacheKey = cacheKey;
      return;
    }
    if (_activityProgressCacheKey == cacheKey ||
        _loadingActivityProgressKeys.contains(cacheKey)) {
      if (_loadingActivityProgressKeys.contains(cacheKey) &&
          selectedGroup.value?.id == group.id &&
          activityProgress.isEmpty) {
        isLoadingActivityProgress.value = true;
      }
      return;
    }
    _loadingActivityProgressKeys.add(cacheKey);
    isLoadingActivityProgress.value = true;
    try {
      final Either<AppError, List<GroupActivityProgressEntity>> result =
          await _groupsRepository.getGroupActivityProgress(
            group.id,
            localDate: _todayKey(),
          );
      result.fold(
        (error) {
          if (selectedGroup.value?.id == group.id) {
            activityProgress.clear();
            _activityProgressCacheKey = null;
          }
        },
        (value) {
          _activityProgressByCacheKey[cacheKey] = value;
          if (selectedGroup.value?.id == group.id) {
            // Copy so clearing the observable later never mutates the cached
            // list (RxList.value assigns by reference).
            activityProgress.value = List.of(value);
            _activityProgressCacheKey = cacheKey;
          }
        },
      );
    } finally {
      _loadingActivityProgressKeys.remove(cacheKey);
      if (selectedGroup.value?.id == group.id) {
        isLoadingActivityProgress.value = false;
      }
    }
  }

  /// One entry per distinct group activity (usually just one), for the tab
  /// header.
  List<GroupActivityProgressEntity> get activityHeaders {
    final Set<String> seen = {};
    final List<GroupActivityProgressEntity> headers = [];
    for (final GroupActivityProgressEntity item in activityProgress) {
      if (seen.add(item.activityId)) {
        headers.add(item);
      }
    }
    return headers;
  }

  GroupActivityProgressEntity? progressFor(String memberId, String activityId) {
    for (final GroupActivityProgressEntity item in activityProgress) {
      if (item.memberId == memberId && item.activityId == activityId) {
        return item;
      }
    }
    return null;
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    return "${now.year.toString().padLeft(4, "0")}-"
        "${now.month.toString().padLeft(2, "0")}-"
        "${now.day.toString().padLeft(2, "0")}";
  }

  void onBackToGroupList() {
    isShowingMemberManagement.value = false;
    isShowingGroupDetails.value = false;
    _closeGroupDetailsRoute();
  }

  void onManageMembers() {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return;
    }
    isShowingMemberManagement.value = true;
  }

  void onBackToGroupDetails() => isShowingMemberManagement.value = false;

  void onSelectPeriod(LeaderboardPeriodType period) {
    if (selectedPeriod.value == period) {
      return;
    }
    selectedPeriod.value = period;
    if (selectedDetailsTab.value == GroupDetailsTab.goals) {
      unawaited(loadActivityProgress());
    }
  }

  void onSelectDetailsTab(GroupDetailsTab tab) {
    _selectDetailsTab(tab);
  }

  void onSwipeDetailsTab(int direction) {
    final List<GroupDetailsTab> tabs = GroupDetailsTab.values;
    final int currentIndex = tabs.indexOf(selectedDetailsTab.value);
    final int nextIndex = (currentIndex + direction)
        .clamp(0, tabs.length - 1)
        .toInt();
    if (nextIndex == currentIndex) {
      return;
    }
    _selectDetailsTab(tabs[nextIndex]);
  }

  void _selectDetailsTab(GroupDetailsTab tab) {
    if (selectedDetailsTab.value == tab) {
      if (tab == GroupDetailsTab.goals &&
          activityProgress.isEmpty &&
          !isLoadingActivityProgress.value) {
        unawaited(loadActivityProgress());
      }
      return;
    }
    selectedDetailsTab.value = tab;
    if (tab == GroupDetailsTab.chat) {
      final String? groupId = selectedGroup.value?.id;
      if (groupId != null) {
        loadImageMessages(groupId);
      }
    }
    if (tab == GroupDetailsTab.goals) {
      unawaited(loadActivityProgress());
    }
  }

  List<GroupImageMessageEntity> imageMessagesFor(String groupId) =>
      imageMessagesByGroup[groupId] ?? const [];

  bool isLoadingOlderImageMessagesFor(String groupId) =>
      _loadingOlderImageMessageGroupIds.contains(groupId);

  Future<void> loadImageMessages(String groupId) async {
    if (imageMessagesByGroup.containsKey(groupId) ||
        _loadingImageMessageGroupIds.contains(groupId)) {
      return;
    }
    _loadingImageMessageGroupIds.add(groupId);
    isLoadingChat.value = true;
    try {
      final Either<AppError, GroupImageMessagesPage> result =
          await _groupsRepository.getImageMessages(groupId);
      result.fold((error) => _appNavigator.showErrorSnackBar(), (page) {
        imageMessagesByGroup[groupId] = page.messages;
        _hasMoreImageMessagesByGroup[groupId] = page.hasMore;
      });
    } finally {
      _loadingImageMessageGroupIds.remove(groupId);
      isLoadingChat.value = false;
    }
  }

  Future<void> loadOlderImageMessages(String groupId) async {
    final List<GroupImageMessageEntity> current = imageMessagesFor(groupId);
    if (current.isEmpty ||
        _hasMoreImageMessagesByGroup[groupId] != true ||
        _loadingImageMessageGroupIds.contains(groupId)) {
      return;
    }

    _loadingImageMessageGroupIds.add(groupId);
    _loadingOlderImageMessageGroupIds.add(groupId);
    try {
      final Either<AppError, GroupImageMessagesPage> result =
          await _groupsRepository.getImageMessages(
            groupId,
            before: current.first,
          );
      result.fold((error) => _appNavigator.showErrorSnackBar(), (page) {
        final List<GroupImageMessageEntity> latest = imageMessagesFor(groupId);
        final Set<String> existingIds = latest.map((item) => item.id).toSet();
        imageMessagesByGroup[groupId] = [
          ...page.messages.where((item) => !existingIds.contains(item.id)),
          ...latest,
        ];
        _hasMoreImageMessagesByGroup[groupId] = page.hasMore;
      });
    } finally {
      _loadingOlderImageMessageGroupIds.remove(groupId);
      _loadingImageMessageGroupIds.remove(groupId);
    }
  }

  Future<void> onTapSendGroupImage(String groupId) async {
    final ImageSource? source = await _pickImageSource();
    if (source == null) {
      return;
    }
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 78,
    );
    if (image == null) {
      return;
    }

    isSendingImage.value = true;
    final List<int> bytes = await image.readAsBytes();
    final Either<AppError, GroupImageMessageEntity> result =
        await _groupsRepository.sendImageMessage(
          groupId: groupId,
          imageBase64: base64Encode(bytes),
        );
    result.fold((error) => _appNavigator.showErrorSnackBar(), (message) {
      final List<GroupImageMessageEntity> current = imageMessagesFor(groupId);
      imageMessagesByGroup[groupId] = [...current, message];
    });
    isSendingImage.value = false;
  }

  Future<void> onTapCreateGroup() async {
    // Get.toNamed<T> with a concrete type crashes at runtime (GetX types the
    // route result future as dynamic internally), so await dynamic and cast.
    final dynamic result = await _appNavigator.toNamed(AppRoutes.createGroup);
    final GroupEntity? newGroup = result as GroupEntity?;
    if (newGroup == null) {
      return;
    }
    final int existingIndex = groups.indexWhere(
      (group) => group.id == newGroup.id,
    );
    if (existingIndex >= 0) {
      groups[existingIndex] = newGroup;
    } else {
      groups.add(newGroup);
    }
    selectedGroup.value = newGroup;
    _activityProgressCacheKey = null;
    activityProgress.clear();
    groups.refresh();
    _mainTabRefreshService.markGroupsChanged();
    // CreateGroupController already writes the owner's local copy of the
    // group activity. Keep that cache intact so the activity appears in "mine"
    // immediately instead of waiting for a remote refetch.
    if (newGroup.theme == GroupThemeType.dailyGoals &&
        Get.isRegistered<DailyGoalsController>()) {
      await Get.find<DailyGoalsController>().loadTasks();
    }
    _appNavigator.showSuccessSnackBar(Get.context!.l10n.groupCreatedSuccess);
  }

  Future<void> upsertJoinedGroup(GroupEntity joinedGroup) async {
    final int existingIndex = groups.indexWhere(
      (group) => group.id == joinedGroup.id,
    );
    if (existingIndex >= 0) {
      groups[existingIndex] = joinedGroup;
    } else {
      groups.add(joinedGroup);
    }
    selectedGroup.value = joinedGroup;
    _activityProgressCacheKey = null;
    activityProgress.clear();
    groups.refresh();
    _mainTabRefreshService.markGroupsChanged();
    await _invalidateActivityCaches();
  }

  Future<void> refreshAfterActivityChange({String? groupId}) async {
    final String? affectedGroupId = groupId ?? selectedGroup.value?.id;
    _activityProgressByCacheKey.clear();
    _activityProgressCacheKey = null;
    await loadGroups(preferredGroupId: affectedGroupId);
    if (selectedGroup.value?.id == affectedGroupId &&
        selectedDetailsTab.value == GroupDetailsTab.goals) {
      activityProgress.clear();
      await loadActivityProgress();
    }
  }

  /// Creating, joining, or editing a group changes the member's group-owned
  /// subjects and goals server-side (fan-out / cleanup trigger). Dropping the
  /// local caches makes the next Category / Daily Goals load refetch them.
  Future<void> _invalidateActivityCaches() async {
    await _localStorageService.delete(LocalStorageKeys.subjects);
    await _localStorageService.delete(LocalStorageKeys.dailyTasks);
    await _reloadVisibleActivityControllers();
  }

  /// Leaving a group must not drop the complete activity caches. A remote
  /// reload can fail or briefly return no rows immediately after the membership
  /// is removed; deleting the caches first would then make every personal goal
  /// and subject disappear from the UI. Remove only the departing group's local
  /// copies and keep all personal items available while the server catches up.
  Future<void> _removeDepartedGroupActivityCaches(String groupId) async {
    await Future.wait([
      _removeGroupItemsFromCache(LocalStorageKeys.subjects, groupId),
      _removeGroupItemsFromCache(LocalStorageKeys.dailyTasks, groupId),
    ]);
    await _reloadVisibleActivityControllers();
  }

  Future<void> _removeGroupItemsFromCache(
    LocalStorageKeys key,
    String groupId,
  ) async {
    final String? encodedItems = await _localStorageService.read<String?>(key);
    if (encodedItems == null) {
      return;
    }

    try {
      final dynamic decodedItems = jsonDecode(encodedItems);
      if (decodedItems is! List<dynamic> ||
          decodedItems.any((item) => item is! Map<String, dynamic>)) {
        return;
      }
      final List<dynamic> retainedItems = decodedItems.where((item) {
        final Map<String, dynamic> cachedItem = item as Map<String, dynamic>;
        return cachedItem["groupId"] != groupId;
      }).toList();
      await _localStorageService.write(key, jsonEncode(retainedItems));
    } on FormatException {
      // Preserve unreadable cache data. The subsequent remote reload may heal
      // it, while deleting it here could hide unrelated personal activities.
    }
  }

  Future<void> _reloadVisibleActivityControllers() async {
    final List<Future<void>> reloads = [];
    if (Get.isRegistered<CategoryController>()) {
      reloads.add(Get.find<CategoryController>().loadSubjects());
    }
    if (Get.isRegistered<DailyGoalsController>()) {
      reloads.add(Get.find<DailyGoalsController>().loadTasks());
    }
    await Future.wait(reloads);
  }

  /// Friends live next to Groups: both answer "how am I doing with others?".
  Future<void> onTapFriends() async {
    await (_appNavigator.toNamed(AppRoutes.friends) ?? Future<void>.value());
    await loadFriends();
  }

  Future<void> onTapInviteMembers() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return;
    }
    await _appNavigator.toNamed<void>(AppRoutes.groupInvites, arguments: group);
  }

  Future<void> onSendFriendRequestToMember(GroupMemberEntity member) async {
    if (isCurrentUser(member) ||
        isFriend(member.id) ||
        hasIncomingFriendRequest(member.id) ||
        sentFriendRequestFor(member.id) != null ||
        !updatingFriendshipMemberIds.add(member.id)) {
      return;
    }
    try {
      final Either<AppError, void> result = await _sendFriendRequestUseCase(
        member.id,
      );
      result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
        sentFriendRequests.add(
          FriendEntity(
            id: member.id,
            friendshipId: "",
            name: member.name,
            handle: "",
            colorValue: member.avatarColorValue,
            avatarIconIndex: member.avatarIconIndex,
            profilePhotoBase64: member.avatar,
          ),
        );
        _appNavigator.showSuccessSnackBar(
          Get.context?.l10n.friendRequestSentMessage ?? "Request sent",
        );
      });
    } finally {
      updatingFriendshipMemberIds.remove(member.id);
    }
  }

  Future<void> onCancelFriendRequestToMember(GroupMemberEntity member) async {
    final FriendEntity? request = sentFriendRequestFor(member.id);
    if (request == null || !updatingFriendshipMemberIds.add(member.id)) {
      return;
    }
    try {
      final Either<AppError, void> result = await _cancelFriendRequestUseCase(
        addresseeId: member.id,
        friendshipId: request.friendshipId,
      );
      result.fold(
        (error) => _appNavigator.showErrorSnackBar(),
        (_) => sentFriendRequests.removeWhere(
          (sentRequest) => sentRequest.id == member.id,
        ),
      );
    } finally {
      updatingFriendshipMemberIds.remove(member.id);
    }
  }

  Future<void> onTapFriendshipMemberAction(GroupMemberEntity member) async {
    final FriendEntity? friend = friends.firstWhereOrNull(
      (item) => item.id == member.id,
    );
    if (friend != null) {
      await onRemoveFriendFromMember(member, friend);
      return;
    }
    if (sentFriendRequestFor(member.id) != null) {
      await onCancelFriendRequestToMember(member);
      return;
    }
    final FriendEntity? incomingRequest = incomingFriendRequests
        .firstWhereOrNull((item) => item.id == member.id);
    if (incomingRequest != null) {
      await onAcceptFriendRequestFromMember(member, incomingRequest);
      return;
    }
    await onSendFriendRequestToMember(member);
  }

  Future<void> onAcceptFriendRequestFromMember(
    GroupMemberEntity member,
    FriendEntity request,
  ) async {
    if (!updatingFriendshipMemberIds.add(member.id)) {
      return;
    }
    try {
      final Either<AppError, void> result = await _acceptFriendRequestUseCase(
        request.friendshipId,
      );
      result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
        incomingFriendRequests.removeWhere((item) => item.id == member.id);
        if (!isFriend(member.id)) {
          friends.add(request);
        }
      });
    } finally {
      updatingFriendshipMemberIds.remove(member.id);
    }
  }

  Future<void> onRemoveFriendFromMember(
    GroupMemberEntity member,
    FriendEntity friend,
  ) async {
    final BuildContext? context = Get.context;
    if (context == null || !updatingFriendshipMemberIds.add(member.id)) {
      return;
    }
    final bool confirmed = await showAppConfirmationDialog(
      title: context.l10n.deleteConfirmationTitle(context.l10n.friendTypeName),
      message: context.l10n.deleteConfirmationContent(friend.name),
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.deleteButton,
      icon: Icons.person_remove_outlined,
      isDestructive: true,
    );
    if (!confirmed) {
      updatingFriendshipMemberIds.remove(member.id);
      return;
    }
    try {
      final Either<AppError, void> result = await _removeFriendUseCase(
        friendId: member.id,
        friendshipId: friend.friendshipId,
      );
      result.fold(
        (error) => _appNavigator.showErrorSnackBar(),
        (_) => friends.removeWhere((item) => item.id == member.id),
      );
    } finally {
      updatingFriendshipMemberIds.remove(member.id);
    }
  }

  Future<void> onRemoveGroupMember(GroupMemberEntity member) async {
    final GroupEntity? group = selectedGroup.value;
    final BuildContext? context = Get.context;
    if (group == null ||
        context == null ||
        isCurrentUser(member) ||
        !_ensureGroupOwner(group) ||
        !updatingGroupMemberIds.add(member.id)) {
      return;
    }
    final bool confirmed = await showAppConfirmationDialog(
      title: context.l10n.deleteConfirmationTitle(
        context.l10n.groupMemberRoleLabel,
      ),
      message: context.l10n.deleteConfirmationContent(member.name),
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.deleteButton,
      icon: Icons.person_remove_outlined,
      isDestructive: true,
    );
    if (!confirmed) {
      updatingGroupMemberIds.remove(member.id);
      return;
    }
    try {
      final Either<AppError, void> result = await _groupsRepository
          .removeMember(groupId: group.id, memberId: member.id);
      await result.fold(
        (error) async => _appNavigator.showErrorSnackBar(),
        (_) => loadGroups(preferredGroupId: group.id),
      );
    } finally {
      updatingGroupMemberIds.remove(member.id);
    }
  }

  Future<void> onTransferGroupLeadership(GroupMemberEntity member) async {
    final GroupEntity? group = selectedGroup.value;
    final BuildContext? context = Get.context;
    if (group == null ||
        context == null ||
        isCurrentUser(member) ||
        !_ensureGroupOwner(group) ||
        !updatingGroupMemberIds.add(member.id)) {
      return;
    }
    final bool confirmed = await showAppConfirmationDialog(
      title: context.l10n.transferGroupLeadershipTitle,
      message: context.l10n.transferGroupLeadershipMessage(member.name),
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.transferGroupLeadershipButton,
      icon: Icons.workspace_premium_outlined,
    );
    if (!confirmed) {
      updatingGroupMemberIds.remove(member.id);
      return;
    }
    try {
      final Either<AppError, void> result = await _groupsRepository
          .transferLeadership(groupId: group.id, nextLeaderId: member.id);
      await result.fold(
        (error) async => _appNavigator.showErrorSnackBar(),
        (_) => loadGroups(preferredGroupId: group.id),
      );
    } finally {
      updatingGroupMemberIds.remove(member.id);
    }
  }

  // Reporting is intentionally only an interface affordance for now.
  void onReportGroupMember(GroupMemberEntity member) {}

  Future<void> onTapEditGroup() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null || !_ensureGroupOwner(group)) {
      return;
    }
    final dynamic result = await _appNavigator.toNamed(
      AppRoutes.editGroup,
      arguments: group,
    );
    final GroupEntity? updatedGroup = result as GroupEntity?;
    if (updatedGroup == null) {
      return;
    }

    final int existingIndex = groups.indexWhere(
      (item) => item.id == updatedGroup.id,
    );
    if (existingIndex >= 0) {
      groups[existingIndex] = updatedGroup;
    }
    selectedGroup.value = updatedGroup;
    _activityProgressByCacheKey.removeWhere(
      (key, value) => key.startsWith("${updatedGroup.id}:"),
    );
    _activityProgressCacheKey = null;
    activityProgress.clear();
    groups.refresh();
    _mainTabRefreshService.markGroupsChanged();
    await _invalidateActivityCaches();
    if (selectedDetailsTab.value == GroupDetailsTab.goals) {
      await loadActivityProgress();
    }
    _appNavigator.showSuccessSnackBar(
      Get.context?.l10n.groupUpdatedSuccess ?? "Group updated successfully",
    );
  }

  Future<void> onTapLeaveGroup() async {
    final GroupEntity? group = selectedGroup.value;
    final BuildContext? context = Get.context;
    if (group == null || context == null) {
      return;
    }
    final bool confirmed = await showAppConfirmationDialog(
      title: context.l10n.leaveGroupConfirmTitle,
      message: context.l10n.leaveGroupConfirmMessage(group.name),
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.leaveGroupConfirmButton,
      icon: Icons.logout_rounded,
      isDestructive: true,
    );
    if (confirmed) {
      await onConfirmLeaveGroup();
    }
  }

  Future<void> onTapResetGroup() async {
    final GroupEntity? group = selectedGroup.value;
    final BuildContext? context = Get.context;
    if (group == null || context == null || !_ensureGroupOwner(group)) {
      return;
    }
    final bool confirmed = await showAppConfirmationDialog(
      title: context.l10n.resetGroupConfirmTitle,
      message: context.l10n.resetGroupConfirmMessage(group.name),
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.resetGroupConfirmButton,
      icon: Icons.restart_alt_rounded,
      isDestructive: true,
    );
    if (!confirmed || selectedGroup.value?.id != group.id) {
      return;
    }
    await onConfirmResetGroup();
  }

  Future<void> onConfirmResetGroup() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null || isResettingGroup.value || !_ensureGroupOwner(group)) {
      return;
    }

    isResettingGroup.value = true;
    try {
      final Either<AppError, void> result = await _groupsRepository
          .resetGroupProgress(group.id);
      await result.fold((error) async => _appNavigator.showErrorSnackBar(), (
        _,
      ) async {
        _activityProgressByCacheKey.removeWhere(
          (key, value) => key.startsWith("${group.id}:"),
        );
        _activityProgressCacheKey = null;
        activityProgress.clear();
        await loadGroups(preferredGroupId: group.id);
        if (selectedDetailsTab.value == GroupDetailsTab.goals) {
          await loadActivityProgress();
        }
        _appNavigator.showSuccessSnackBar(
          Get.context?.l10n.groupResetSuccess ??
              "The group's progress and ranking were reset.",
        );
      });
    } finally {
      isResettingGroup.value = false;
    }
  }

  bool _ensureGroupOwner(GroupEntity group) {
    if (isGroupOwner(group)) {
      return true;
    }
    _appNavigator.showErrorSnackBar(
      Get.context?.l10n.ownerOnlyGroupActionError ??
          "Only the group owner can do this.",
    );
    return false;
  }

  Future<void> onConfirmLeaveGroup() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return;
    }

    final Either<AppError, void> result = await _groupsRepository.leaveGroup(
      group.id,
    );
    await result.fold((error) async => _appNavigator.showErrorSnackBar(), (
      _,
    ) async {
      groups.removeWhere((item) => item.id == group.id);
      imageMessagesByGroup.remove(group.id);
      _hasMoreImageMessagesByGroup.remove(group.id);
      _activityProgressByCacheKey.removeWhere(
        (key, value) => key.startsWith("${group.id}:"),
      );
      _activityProgressCacheKey = null;
      activityProgress.clear();
      selectedGroup.value = groups.isEmpty ? null : groups.first;
      isShowingMemberManagement.value = false;
      isShowingGroupDetails.value = false;
      groups.refresh();
      _mainTabRefreshService.markGroupsChanged();
      await _removeDepartedGroupActivityCaches(group.id);
      _closeGroupDetailsRoute();
      _appNavigator.showSuccessSnackBar(
        Get.context?.l10n.leftGroupMessage ?? "You left the group.",
      );
    });
  }

  Future<ImageSource?> _pickImageSource() {
    final BuildContext? context = Get.context;
    if (context == null) {
      return Future<ImageSource?>.value(null);
    }
    return showPhotoSourceBottomSheet(
      context: context,
      title: context.l10n.groupImageSourceTitle,
      subtitle: context.l10n.groupImageSourceSubtitle,
      cameraLabel: context.l10n.photoCameraLabel,
      galleryLabel: context.l10n.photoGalleryLabel,
    );
  }

  void _closeGroupDetailsRoute() {
    if (Get.currentRoute == AppRoutes.groupDetails) {
      _appNavigator.back<void>();
    }
  }
}
