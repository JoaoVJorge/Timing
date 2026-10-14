import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/sync/group_activity_link_sync.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

/// A group is its name and its theme. The theme decides which of the creator's
/// own activities can already be linked to it; nothing is created for the
/// group itself.
class CreateGroupController extends GetxController {
  CreateGroupController({
    required this._groupsRepository,
    this.dailyTasksRepository,
    this.subjectsRepository,
    required this._appNavigator,
  });

  static const int lastStep = 2;

  final GroupsRepository _groupsRepository;
  final DailyTasksRepository? dailyTasksRepository;
  final SubjectsRepository? subjectsRepository;
  final AppNavigator _appNavigator;

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController friendSearchController = TextEditingController();

  final RxList<FriendOption> availableFriends = <FriendOption>[].obs;
  final RxSet<String> selectedFriendIds = <String>{}.obs;
  final Rx<GroupThemeType?> selectedTheme = Rx<GroupThemeType?>(null);
  final RxString groupName = "".obs;
  final RxString groupDescription = "".obs;
  final RxString friendSearchQuery = "".obs;

  final RxBool isLoadingSources = false.obs;
  final RxBool sourcesLoadFailed = false.obs;
  final RxSet<String> selectedSourceIds = <String>{}.obs;
  final RxList<SubjectEntity> personalSubjects = <SubjectEntity>[].obs;
  final RxList<DailyTaskEntity> personalTasks = <DailyTaskEntity>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasLoadError = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool canCreate = false.obs;
  final RxInt currentStep = 0.obs;

  bool get hasName => groupName.value.trim().isNotEmpty;

  bool get hasTheme => selectedTheme.value != null;

  bool get isDailyGoalsTheme =>
      selectedTheme.value == GroupThemeType.dailyGoals;

  bool get hasFriends => selectedFriendIds.isNotEmpty;

  bool get isInformationStep => currentStep.value == 0;

  bool get isFriendsStep => currentStep.value == 1;

  bool get isSummaryStep => currentStep.value == lastStep;

  /// The creator's own activities that fit the chosen theme: goals for a
  /// daily-goals group, otherwise the activities of the theme's category.
  List<GroupActivitySourceOption> get compatibleSources {
    final GroupThemeType? theme = selectedTheme.value;
    if (theme == null) {
      return const [];
    }
    final TimeCategoryType? category = theme.category;
    if (category == null) {
      return [
        for (final DailyTaskEntity task in personalTasks)
          GroupActivitySourceOption(id: task.id, name: task.name),
      ];
    }
    return [
      for (final SubjectEntity subject in personalSubjects)
        if (subject.category == category)
          GroupActivitySourceOption(id: subject.id, name: subject.name),
    ];
  }

  List<GroupActivitySourceOption> get selectedSources => compatibleSources
      .where((source) => selectedSourceIds.contains(source.id))
      .toList();

  List<FriendOption> get filteredFriends {
    final String query = friendSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return availableFriends;
    }
    return availableFriends
        .where((friend) => friend.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    groupNameController.addListener(_syncGroupName);
    descriptionController.addListener(
      () => groupDescription.value = descriptionController.text,
    );
    loadFriends();
    loadPersonalActivities();
  }

  Future<void> loadFriends() async {
    isLoading.value = true;
    hasLoadError.value = false;
    final Either<AppError, List<FriendOption>> result = await _groupsRepository
        .getInvitableFriends();
    result.fold((error) {
      availableFriends.clear();
      hasLoadError.value = true;
    }, (friends) => availableFriends.value = friends);
    isLoading.value = false;
  }

  Future<void> loadPersonalActivities() async {
    isLoadingSources.value = true;
    sourcesLoadFailed.value = false;
    final subjects = await subjectsRepository?.getSubjects();
    subjects?.fold(
      (_) => sourcesLoadFailed.value = true,
      personalSubjects.assignAll,
    );
    final tasks = await dailyTasksRepository?.getTasks();
    tasks?.fold((_) => sourcesLoadFailed.value = true, personalTasks.assignAll);
    isLoadingSources.value = false;
  }

  void onGroupNameChanged(String value) {
    if (groupName.value != value) {
      groupName.value = value;
    }
    _refreshCanCreate();
  }

  void _syncGroupName() => onGroupNameChanged(groupNameController.text);

  void onFriendSearchChanged(String value) => friendSearchQuery.value = value;

  void onSelectTheme(GroupThemeType theme) {
    // What was picked for another theme cannot be linked to this one.
    if (selectedTheme.value != theme) selectedSourceIds.clear();
    selectedTheme.value = theme;
    _refreshCanCreate();
  }

  /// A daily-goals group takes a single goal, so choosing another replaces
  /// the current one. Tapping the chosen one clears it.
  void toggleSource(String id) {
    if (selectedSourceIds.remove(id)) {
      return;
    }
    if (!compatibleSources.any((source) => source.id == id)) {
      return;
    }
    if (isDailyGoalsTheme) {
      selectedSourceIds.clear();
    }
    selectedSourceIds.add(id);
  }

  void onTapBack() {
    if (currentStep.value == 0) {
      _appNavigator.back();
      return;
    }
    currentStep.value--;
  }

  void _refreshCanCreate() =>
      canCreate.value = hasName && hasTheme && hasFriends;

  void onToggleFriend(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
    } else {
      selectedFriendIds.add(friendId);
    }
    _refreshCanCreate();
  }

  Future<void> onTapAddFriends() async {
    await _appNavigator.toNamed<void>(AppRoutes.friends);
    await loadFriends();
  }

  void onTapContinue() {
    if (isInformationStep) {
      if (!hasName) {
        _appNavigator.showErrorSnackBar(Get.context!.l10n.nameRequiredError);
        return;
      }
      if (!hasTheme) {
        _appNavigator.showErrorSnackBar(
          Get.context!.l10n.groupThemeRequiredError,
        );
        return;
      }
      currentStep.value = 1;
      return;
    }

    if (isFriendsStep) {
      if (selectedFriendIds.isEmpty) {
        _appNavigator.showErrorSnackBar(
          Get.context!.l10n.groupNeedsFriendError,
        );
        return;
      }
      currentStep.value = lastStep;
      return;
    }
  }

  Future<void> onTapCreate() async {
    if (isCreating.value) {
      return;
    }

    final String name = groupNameController.text.trim();
    final GroupThemeType? theme = selectedTheme.value;
    if (name.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.nameRequiredError);
      return;
    }
    if (theme == null) {
      _appNavigator.showErrorSnackBar(
        Get.context!.l10n.groupThemeRequiredError,
      );
      return;
    }
    if (selectedFriendIds.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.groupNeedsFriendError);
      return;
    }
    isCreating.value = true;
    final List<String> linkedSourceIds = [
      for (final GroupActivitySourceOption source in selectedSources) source.id,
    ];
    if (linkedSourceIds.isNotEmpty &&
        !await preparePersonalActivitiesForLinking()) {
      isCreating.value = false;
      _appNavigator.showErrorSnackBar(Get.context!.l10n.groupLinksSyncError);
      return;
    }
    final List<FriendOption> invitedFriends = availableFriends
        .where((friend) => selectedFriendIds.contains(friend.id))
        .toList();
    final Either<AppError, GroupEntity> result = await _groupsRepository
        .createGroup(
          name: name,
          theme: theme,
          invitedFriends: invitedFriends,
          description: descriptionController.text.trim(),
          linkedSourceIds: linkedSourceIds,
        );
    result.fold(
      (error) => _appNavigator.showError(error),
      (group) => Get.back<GroupEntity>(result: group, closeOverlays: true),
    );
    isCreating.value = false;
  }

  @override
  void onClose() {
    groupNameController.removeListener(_syncGroupName);
    groupNameController.dispose();
    descriptionController.dispose();
    friendSearchController.dispose();
    super.onClose();
  }
}
