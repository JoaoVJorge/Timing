import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_groups_use_case.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/shared/widgets/photo_source_bottom_sheet.dart";
import "package:image_picker/image_picker.dart";

enum GroupDetailsTab { ranking, goals, chat }

class GroupsController extends GetxController {
  GroupsController({
    required this._getGroupsUseCase,
    required this._groupsRepository,
    required this._appNavigator,
    required this._supabaseService,
    required this._localStorageService,
  });

  final GetGroupsUseCase _getGroupsUseCase;
  final GroupsRepository _groupsRepository;
  final AppNavigator _appNavigator;
  final SupabaseService _supabaseService;
  final AppLocalStorageService _localStorageService;
  final ImagePicker _imagePicker = ImagePicker();

  final RxList<GroupEntity> groups = <GroupEntity>[].obs;
  final Rx<GroupEntity?> selectedGroup = Rx<GroupEntity?>(null);
  final Rx<LeaderboardPeriodType> selectedPeriod =
      LeaderboardPeriodType.today.obs;
  final Rx<GroupDetailsTab> selectedDetailsTab = GroupDetailsTab.ranking.obs;
  final RxBool isLoading = true.obs;
  final RxBool isShowingGroupDetails = false.obs;
  final RxBool isShowingMemberManagement = false.obs;
  final RxBool isLoadingActivityProgress = false.obs;
  final RxBool isLoadingChat = false.obs;
  final RxBool isSendingImage = false.obs;
  final RxBool didFailLoadingGroups = false.obs;
  final RxMap<String, List<GroupImageMessageEntity>> imageMessagesByGroup =
      <String, List<GroupImageMessageEntity>>{}.obs;
  final RxList<GroupActivityProgressEntity> activityProgress =
      <GroupActivityProgressEntity>[].obs;

  String get currentUserId => _supabaseService.currentUserId ?? "";

  /// Sorting the members is cheap on its own, but the ranking tab reads this
  /// getter (directly and through `rankOf`/`differenceToPrevious`) dozens of
  /// times per rebuild, so the sorted list is cached until the selected group
  /// or period changes. `selectedGroup.value` is always reassigned on a change,
  /// so an identity check is enough to invalidate.
  GroupEntity? _rankedCacheGroup;
  LeaderboardPeriodType? _rankedCachePeriod;
  List<GroupMemberEntity> _rankedCache = const [];
  String? _activityProgressCacheKey;
  final Set<String> _loadingActivityProgressKeys = <String>{};
  final Map<String, List<GroupActivityProgressEntity>>
  _activityProgressByCacheKey = <String, List<GroupActivityProgressEntity>>{};
  final Set<String> _loadingImageMessageGroupIds = <String>{};
  static const Duration _groupsLoadTimeout = Duration(seconds: 20);

  List<GroupMemberEntity> get rankedMembers {
    final GroupEntity? group = selectedGroup.value;
    final LeaderboardPeriodType period = selectedPeriod.value;
    if (group == null) {
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
    return members;
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
    return member == null ? 0 : rankOf(member);
  }

  int rankOf(GroupMemberEntity member) {
    final int value = member.secondsFor(selectedPeriod.value);
    return rankedMembers
            .where((item) => item.secondsFor(selectedPeriod.value) > value)
            .length +
        1;
  }

  bool get currentUserIsTiedForFirst {
    final GroupMemberEntity? member = currentUserMember;
    if (member == null || rankOf(member) != 1) {
      return false;
    }
    final int value = member.secondsFor(selectedPeriod.value);
    return rankedMembers
            .where((item) => item.secondsFor(selectedPeriod.value) == value)
            .length >
        1;
  }

  /// Member ranked immediately above the current user, used to turn "2nd place"
  /// into a concrete target.
  GroupMemberEntity? get memberAheadOfCurrentUser {
    final List<GroupMemberEntity> members = rankedMembers;
    final int index = members.indexWhere(isCurrentUser);
    if (index <= 0) {
      return null;
    }
    final int currentValue = members[index].secondsFor(selectedPeriod.value);
    for (int i = index - 1; i >= 0; i--) {
      if (members[i].secondsFor(selectedPeriod.value) > currentValue) {
        return members[i];
      }
    }
    return null;
  }

  int? differenceToPrevious(GroupMemberEntity member) {
    final List<GroupMemberEntity> members = rankedMembers;
    final int index = members.indexWhere((item) => item.id == member.id);
    if (index <= 0) {
      return null;
    }
    final int value = member.secondsFor(selectedPeriod.value);
    GroupMemberEntity? previous;
    for (int i = index - 1; i >= 0; i--) {
      if (members[i].secondsFor(selectedPeriod.value) > value) {
        previous = members[i];
        break;
      }
    }
    if (previous == null) {
      return 0;
    }
    return previous.secondsFor(selectedPeriod.value) - value;
  }

  bool isCurrentUser(GroupMemberEntity member) => member.id == currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
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
          // Copy so the controller's list doesn't alias the data source's mutable
          // store — otherwise a created group appears in both the store add and the
          // controller add below, showing up twice.
          groups.value = List.of(value);
          selectedGroup.value = value.isEmpty ? null : value.first;
        },
      );
    } on TimeoutException {
      didFailLoadingGroups.value = true;
      _appNavigator.showErrorSnackBar();
    } finally {
      isLoading.value = false;
    }
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
  /// group's "Metas" tab to mark who reached the goal.
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

  int reachedCount(String activityId) => activityProgress
      .where((item) => item.activityId == activityId && item.reached)
      .length;

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

  void onManageMembers() => isShowingMemberManagement.value = true;

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

  Future<void> loadImageMessages(String groupId) async {
    if (imageMessagesByGroup.containsKey(groupId) ||
        _loadingImageMessageGroupIds.contains(groupId)) {
      return;
    }
    _loadingImageMessageGroupIds.add(groupId);
    isLoadingChat.value = true;
    try {
      final Either<AppError, List<GroupImageMessageEntity>> result =
          await _groupsRepository.getImageMessages(groupId);
      result.fold(
        (error) => _appNavigator.showErrorSnackBar(),
        (messages) => imageMessagesByGroup[groupId] = messages,
      );
    } finally {
      _loadingImageMessageGroupIds.remove(groupId);
      isLoadingChat.value = false;
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
    await _invalidateActivityCaches();
  }

  Future<void> refreshAfterActivityChange() async {
    _activityProgressByCacheKey.clear();
    _activityProgressCacheKey = null;
    await loadGroups();
    if (selectedGroup.value != null &&
        selectedDetailsTab.value == GroupDetailsTab.goals) {
      activityProgress.clear();
      await loadActivityProgress();
    }
  }

  /// Creating, joining, or leaving a group changes the member's group-owned
  /// subjects and goals server-side (fan-out / cleanup trigger). Dropping the
  /// local caches makes the next Category / Daily Goals load refetch them.
  Future<void> _invalidateActivityCaches() async {
    await _localStorageService.delete(LocalStorageKeys.subjects);
    await _localStorageService.delete(LocalStorageKeys.dailyTasks);
  }

  /// Friends live next to Groups: both answer "how am I doing with others?".
  Future<void> onTapFriends() =>
      _appNavigator.toNamed(AppRoutes.friends) ?? Future<void>.value();

  Future<void> onTapInviteMembers() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return;
    }
    await _appNavigator.toNamed<void>(AppRoutes.groupInvites, arguments: group);
  }

  void onTapEditGroup() {
    final String message =
        Get.context?.l10n.groupEditingComingSoon ??
        "Group editing is coming soon.";
    _appNavigator.showSnackBar(text: message);
  }

  Future<void> onTapLeaveGroup() async {
    await onConfirmLeaveGroup();
  }

  Future<void> onConfirmLeaveGroup() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return;
    }

    final Either<AppError, void> result = await _groupsRepository.leaveGroup(
      group.id,
    );
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      groups.removeWhere((item) => item.id == group.id);
      imageMessagesByGroup.remove(group.id);
      _activityProgressByCacheKey.removeWhere(
        (key, value) => key.startsWith("${group.id}:"),
      );
      _activityProgressCacheKey = null;
      activityProgress.clear();
      selectedGroup.value = groups.isEmpty ? null : groups.first;
      isShowingMemberManagement.value = false;
      isShowingGroupDetails.value = false;
      groups.refresh();
      unawaited(_invalidateActivityCaches());
      _closeGroupDetailsRoute();
      _appNavigator.showSuccessSnackBar(
        Get.context?.l10n.leftGroupMessage ?? "You left the group.",
      );
    });
  }

  Future<void> onTapJoinWithCode() async {
    final dynamic result = await _appNavigator.toNamed(AppRoutes.joinGroup);
    final GroupEntity? joinedGroup = result as GroupEntity?;
    if (joinedGroup == null) {
      return;
    }
    await upsertJoinedGroup(joinedGroup);
    onSelectGroup(joinedGroup);
    _appNavigator.showSuccessSnackBar(
      Get.context?.l10n.joinedGroupMessage ?? "You joined the group",
    );
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
