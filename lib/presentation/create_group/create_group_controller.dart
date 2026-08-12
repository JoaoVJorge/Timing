import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_activity_draft.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/core/domain/use_cases/create_group_use_case.dart";
import "package:help_out/core/domain/use_cases/get_invitable_friends_use_case.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";

/// The kinds of activity a group can hand out: the four subject categories plus
/// a daily-goal ("meta"). Maps to a [TimeCategoryType] for subjects, or `null`
/// for goals.
enum GroupActivityOption { studying, exercises, reading, hobbies, goal }

extension GroupActivityOptionX on GroupActivityOption {
  TimeCategoryType? get category => switch (this) {
    GroupActivityOption.studying => TimeCategoryType.studying,
    GroupActivityOption.exercises => TimeCategoryType.exercises,
    GroupActivityOption.reading => TimeCategoryType.reading,
    GroupActivityOption.hobbies => TimeCategoryType.hobbies,
    GroupActivityOption.goal => null,
  };

  bool get isGoal => this == GroupActivityOption.goal;

  bool get isReading => this == GroupActivityOption.reading;
}

class CreateGroupController extends GetxController {
  CreateGroupController({
    required this._getInvitableFriendsUseCase,
    required this._createGroupUseCase,
    required this._appNavigator,
  });

  static const int lastStep = 3;

  final GetInvitableFriendsUseCase _getInvitableFriendsUseCase;
  final CreateGroupUseCase _createGroupUseCase;
  final AppNavigator _appNavigator;

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController friendSearchController = TextEditingController();
  final TextEditingController activityNameController = TextEditingController();
  final TextEditingController activityGoalController = TextEditingController();

  final RxList<FriendOption> availableFriends = <FriendOption>[].obs;
  final RxSet<String> selectedFriendIds = <String>{}.obs;
  final Rx<GroupThemeType?> selectedTheme = Rx<GroupThemeType?>(null);
  final RxString groupName = "".obs;
  final RxString groupDescription = "".obs;
  final RxString friendSearchQuery = "".obs;

  final Rx<GroupActivityOption?> activityOption = Rx<GroupActivityOption?>(
    null,
  );
  final RxString activityName = "".obs;
  final RxString activityGoal = "".obs;
  final Rx<Color> activityColor = SubjectColors.values.first.obs;
  final Rx<DailyTaskGoalType> activityGoalType = DailyTaskGoalType.total.obs;

  final RxBool isLoading = true.obs;
  final RxBool hasLoadError = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool canCreate = false.obs;
  final RxInt currentStep = 0.obs;

  bool get hasName => groupName.value.trim().isNotEmpty;

  bool get hasTheme => selectedTheme.value != null;

  bool get hasFriends => selectedFriendIds.isNotEmpty;

  bool get isInformationStep => currentStep.value == 0;

  bool get isActivityStep => currentStep.value == 1;

  bool get isFriendsStep => currentStep.value == 2;

  bool get isSummaryStep => currentStep.value == lastStep;

  bool get hasActivityType => activityOption.value != null;

  bool get isGoalActivity => activityOption.value?.isGoal ?? false;

  bool get isReadingActivity => activityOption.value?.isReading ?? false;

  bool get hasValidActivityGoal {
    final GroupActivityOption? option = activityOption.value;
    if (option == null) {
      return false;
    }
    if (option.isGoal) {
      if (activityGoalType.value == DailyTaskGoalType.daily) {
        return true;
      }
      return (int.tryParse(activityGoal.value.trim()) ?? 0) > 0;
    }
    return (int.tryParse(activityGoal.value.trim()) ?? 0) > 0;
  }

  bool get hasActivity =>
      hasActivityType &&
      activityName.value.trim().isNotEmpty &&
      hasValidActivityGoal;

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
    activityNameController.addListener(() {
      activityName.value = activityNameController.text;
      _refreshCanCreate();
    });
    activityGoalController.addListener(() {
      activityGoal.value = activityGoalController.text;
      _refreshCanCreate();
    });
    loadFriends();
  }

  Future<void> loadFriends() async {
    isLoading.value = true;
    hasLoadError.value = false;
    final Either<AppError, List<FriendOption>> result =
        await _getInvitableFriendsUseCase();
    result.fold((error) {
      availableFriends.clear();
      hasLoadError.value = true;
    }, (friends) => availableFriends.value = friends);
    isLoading.value = false;
  }

  void onGroupNameChanged(String value) {
    if (groupName.value != value) {
      groupName.value = value;
    }
    _refreshCanCreate();
  }

  void _syncGroupName() {
    final String value = groupNameController.text;
    if (groupName.value == value) {
      return;
    }
    groupName.value = value;
    _refreshCanCreate();
  }

  void onFriendSearchChanged(String value) => friendSearchQuery.value = value;

  void onSelectTheme(GroupThemeType theme) {
    selectedTheme.value = theme;
    _refreshCanCreate();
  }

  void onSelectActivityOption(GroupActivityOption option) {
    activityOption.value = option;
    if (activityGoalController.text.trim().isEmpty) {
      activityGoalController.text = switch (option) {
        GroupActivityOption.goal => "7",
        GroupActivityOption.reading => "10",
        _ => "30",
      };
    }
    activityGoal.value = activityGoalController.text;
    _refreshCanCreate();
  }

  void onSelectActivityColor(Color color) => activityColor.value = color;

  void onSelectActivitySequenceType(DailyTaskSequenceType type) {
    activityGoalType.value = type == DailyTaskSequenceType.intense
        ? DailyTaskGoalType.daily
        : DailyTaskGoalType.total;
    _refreshCanCreate();
  }

  void onSelectActivityGoalType(DailyTaskGoalType type) {
    activityGoalType.value = type;
    _refreshCanCreate();
  }

  void onTapBack() {
    if (currentStep.value == 0) {
      _appNavigator.back();
      return;
    }
    currentStep.value--;
  }

  void _refreshCanCreate() =>
      canCreate.value = hasName && hasTheme && hasActivity && hasFriends;

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

    if (isActivityStep) {
      if (!hasActivityType) {
        _appNavigator.showErrorSnackBar("Escolha uma atividade para o grupo.");
        return;
      }
      if (activityName.value.trim().isEmpty) {
        _appNavigator.showErrorSnackBar("Dê um nome para a atividade.");
        return;
      }
      if (!hasValidActivityGoal) {
        _appNavigator.showErrorSnackBar("Defina uma meta válida.");
        return;
      }
      currentStep.value = 2;
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

  GroupActivityDraft? buildActivityDraft() {
    final GroupActivityOption? option = activityOption.value;
    if (option == null) {
      return null;
    }
    final String name = activityNameController.text.trim();
    if (name.isEmpty) {
      return null;
    }
    final int colorValue = activityColor.value.toARGB32();

    if (option.isGoal) {
      final bool isDaily = activityGoalType.value == DailyTaskGoalType.daily;
      final int targetDays = isDaily
          ? 1
          : (int.tryParse(activityGoalController.text.trim()) ?? 0);
      if (targetDays <= 0) {
        return null;
      }
      return GroupActivityDraft.goal(
        name: name,
        colorValue: colorValue,
        targetDays: targetDays,
        sequenceType: activityGoalType.value == DailyTaskGoalType.daily
            ? DailyTaskSequenceType.intense.name
            : DailyTaskSequenceType.casual.name,
        goalType: activityGoalType.value.name,
      );
    }

    final TimeCategoryType category = option.category!;
    final int goalNumber =
        int.tryParse(activityGoalController.text.trim()) ?? 0;
    if (goalNumber <= 0) {
      return null;
    }
    final bool isReading = category == TimeCategoryType.reading;
    return GroupActivityDraft.subject(
      name: name,
      category: category,
      colorValue: colorValue,
      goalSeconds: isReading ? 0 : goalNumber * 60,
      goalPages: isReading ? goalNumber : 0,
      iconName: SubjectIcons.suggestionsFor(category).first,
    );
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
    if (!hasActivity) {
      _appNavigator.showErrorSnackBar("Defina a atividade do grupo.");
      return;
    }
    if (selectedFriendIds.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.groupNeedsFriendError);
      return;
    }
    isCreating.value = true;
    final List<FriendOption> invitedFriends = availableFriends
        .where((friend) => selectedFriendIds.contains(friend.id))
        .toList();
    final Either<AppError, GroupEntity> result = await _createGroupUseCase(
      name: name,
      theme: theme,
      invitedFriends: invitedFriends,
      description: descriptionController.text.trim(),
      activity: buildActivityDraft(),
    );
    isCreating.value = false;

    result.fold(
      (error) => _appNavigator.showErrorSnackBar(error.message),
      (group) => Get.back<GroupEntity>(result: group, closeOverlays: true),
    );
  }

  @override
  void onClose() {
    groupNameController.removeListener(_syncGroupName);
    groupNameController.dispose();
    descriptionController.dispose();
    friendSearchController.dispose();
    activityNameController.dispose();
    activityGoalController.dispose();
    super.onClose();
  }
}
