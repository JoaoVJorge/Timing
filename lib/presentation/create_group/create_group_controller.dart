import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_activity_draft.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/core/domain/use_cases/create_group_use_case.dart";
import "package:help_out/core/domain/use_cases/get_invitable_friends_use_case.dart";
import "package:help_out/presentation/create_subject/subject_creation_form_controller.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";

class CreateGroupController extends GetxController
    implements SubjectCreationFormController {
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

  final RxString activityName = "".obs;
  final RxString activityGoal = "".obs;
  @override
  final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  @override
  final RxString selectedIconName = SubjectIcons.suggestionsFor(
    TimeCategoryType.studying,
  ).first.obs;
  @override
  final RxInt restMinutes = SubjectEntity.defaultRestMinutes.obs;
  @override
  final RxInt focusSessionCount = 1.obs;
  @override
  final RxInt wallpaperIndex = 0.obs;
  @override
  final Rx<SubjectActivityType> activityType = SubjectActivityType.daily.obs;

  final RxBool isLoading = true.obs;
  final RxBool hasLoadError = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool canCreate = false.obs;
  final RxInt currentStep = 0.obs;
  GroupThemeType? _themeUsedForActivityDefaults;
  bool _hasInitializedThemeColor = false;

  bool get hasName => groupName.value.trim().isNotEmpty;

  bool get hasTheme => selectedTheme.value != null;

  bool get hasFriends => selectedFriendIds.isNotEmpty;

  bool get isInformationStep => currentStep.value == 0;

  bool get isActivityStep => currentStep.value == 1;

  bool get isFriendsStep => currentStep.value == 2;

  bool get isSummaryStep => currentStep.value == lastStep;

  @override
  bool get isPageBased => category == TimeCategoryType.reading;

  @override
  RxString get goal => activityGoal;

  @override
  List<String> get iconSuggestions => SubjectIcons.suggestionsFor(category);

  @override
  List<int> get restMinutesOptions => const [5, 10, 15, 20];

  @override
  List<int> get focusSessionCountOptions => const [1, 2, 3, 4];

  @override
  List<int> get timeGoalPresets => const [15, 30, 45, 60];

  @override
  List<int> get pageGoalPresets => const [5, 10, 25, 50];

  @override
  TextEditingController get nameController => activityNameController;

  @override
  TextEditingController get goalController => activityGoalController;

  @override
  TimeCategoryType get category => switch (selectedTheme.value) {
    GroupThemeType.exercises => TimeCategoryType.exercises,
    GroupThemeType.reading => TimeCategoryType.reading,
    GroupThemeType.hobbies => TimeCategoryType.hobbies,
    _ => TimeCategoryType.studying,
  };

  bool get hasValidActivityGoal =>
      (int.tryParse(activityGoal.value.trim()) ?? 0) > 0;

  bool get hasActivity =>
      activityName.value.trim().isNotEmpty && hasValidActivityGoal;

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
    _applyThemeActivityDefaults(forceIcon: true);
    _refreshCanCreate();
  }

  void _applyThemeActivityDefaults({bool forceIcon = false}) {
    final GroupThemeType? theme = selectedTheme.value;
    if (theme == null) {
      return;
    }
    if (!forceIcon && _themeUsedForActivityDefaults == theme) {
      return;
    }
    _themeUsedForActivityDefaults = theme;
    selectedIconName.value = SubjectIcons.suggestionsFor(category).first;
    if (activityGoalController.text.trim().isEmpty) {
      activityGoalController.text = isPageBased ? "10" : "30";
      activityGoal.value = activityGoalController.text;
    }
  }

  @override
  void initializeThemeColor(Color color) {
    if (_hasInitializedThemeColor) {
      return;
    }
    selectedColor.value = SubjectColors.fromThemeAccent(color);
    _hasInitializedThemeColor = true;
  }

  @override
  String title(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectTitleStudying,
    TimeCategoryType.reading => context.l10n.createSubjectTitleReading,
    TimeCategoryType.exercises => context.l10n.createSubjectTitleExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectTitleHobbies,
  };

  @override
  String subtitle(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectSubtitleStudying,
    TimeCategoryType.reading => context.l10n.createSubjectSubtitleReading,
    TimeCategoryType.exercises => context.l10n.createSubjectSubtitleExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectSubtitleHobbies,
  };

  @override
  String nameHint(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectNameHintStudying,
    TimeCategoryType.reading => context.l10n.createSubjectNameHintReading,
    TimeCategoryType.exercises => context.l10n.createSubjectNameHintExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectNameHintHobbies,
  };

  @override
  void setActivityType(SubjectActivityType type) {
    activityType.value = type;
  }

  @override
  void setGoalPreset(int value) {
    activityGoalController.text = value.toString();
    activityGoal.value = activityGoalController.text;
  }

  @override
  void setRestMinutes(int minutes) {
    restMinutes.value = minutes;
  }

  @override
  void setFocusSessionCount(int count) {
    focusSessionCount.value = count;
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
      _applyThemeActivityDefaults();
      currentStep.value = 1;
      return;
    }

    if (isActivityStep) {
      if (activityName.value.trim().isEmpty) {
        _appNavigator.showErrorSnackBar(
          Get.context!.l10n.createGroupActivityNameRequiredError,
        );
        return;
      }
      if (!hasValidActivityGoal) {
        _appNavigator.showErrorSnackBar(
          Get.context!.l10n.createGroupActivityGoalInvalidError,
        );
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
    final String name = activityNameController.text.trim();
    if (name.isEmpty) {
      return null;
    }
    final int colorValue = selectedColor.value.toARGB32();
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
      iconName: selectedIconName.value,
      restMinutes: restMinutes.value,
      focusSessionCount: focusSessionCount.value,
      wallpaperIndex: wallpaperIndex.value,
      activityType: activityType.value.name,
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
      _appNavigator.showErrorSnackBar(
        Get.context!.l10n.createGroupActivityMissingError,
      );
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
