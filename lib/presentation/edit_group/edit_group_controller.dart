import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/groups/groups_controller.dart";

class EditGroupController extends GetxController {
  EditGroupController({
    required this.groupsRepository,
    required this.appNavigator,
  });

  final GroupsRepository groupsRepository;
  final AppNavigator appNavigator;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController activityNameController = TextEditingController();
  final TextEditingController activityGoalController = TextEditingController();
  final TextEditingController restController = TextEditingController();
  final TextEditingController sessionsController = TextEditingController();

  final Rx<GroupEntity?> group = Rx<GroupEntity?>(null);
  final Rx<GroupActivityProgressEntity?> activity =
      Rx<GroupActivityProgressEntity?>(null);
  final RxBool isLoadingActivity = false.obs;
  final RxBool isSaving = false.obs;

  GroupThemeType? get theme => group.value?.theme;

  bool get isDailyGoalsTheme => theme == GroupThemeType.dailyGoals;

  bool get isReadingTheme => theme == GroupThemeType.reading;

  bool get showRestAndSessions => !isDailyGoalsTheme && !isReadingTheme;

  String get goalSuffix {
    if (isDailyGoalsTheme) {
      return "dias";
    }
    if (isReadingTheme) {
      return "pags.";
    }
    return "min";
  }

  String get restSuffix => theme == GroupThemeType.exercises ? "s" : "min";

  @override
  void onInit() {
    super.onInit();
    final Object? args = appNavigator.arguments;
    final GroupEntity? initialGroup = args is GroupEntity
        ? args
        : Get.isRegistered<GroupsController>()
        ? Get.find<GroupsController>().selectedGroup.value
        : null;
    group.value = initialGroup;
    if (initialGroup != null) {
      nameController.text = initialGroup.name;
      descriptionController.text = initialGroup.description;
    }
    _loadCurrentActivity();
  }

  Future<void> _loadCurrentActivity() async {
    if (!Get.isRegistered<GroupsController>()) {
      return;
    }
    final GroupsController groupsController = Get.find<GroupsController>();
    GroupActivityProgressEntity? header =
        groupsController.activityHeaders.firstOrNull;
    if (header == null && group.value != null) {
      isLoadingActivity.value = true;
      await groupsController.loadActivityProgress();
      header = groupsController.activityHeaders.firstOrNull;
      isLoadingActivity.value = false;
    }
    activity.value = header;
    _fillActivityFields(header);
  }

  void _fillActivityFields(GroupActivityProgressEntity? header) {
    if (header == null) {
      return;
    }
    activityNameController.text = header.name;
    activityGoalController.text = _goalValueFrom(header).toString();
    restController.text = header.restMinutes.toString();
    sessionsController.text = header.focusSessionCount.toString();
  }

  int _goalValueFrom(GroupActivityProgressEntity header) {
    if (isDailyGoalsTheme || isReadingTheme) {
      return header.target > 0 ? header.target : 1;
    }
    final int seconds = header.focusSeconds > 0
        ? header.focusSeconds
        : header.target;
    return (seconds / 60).round().clamp(1, 9999);
  }

  Future<void> save() async {
    if (isSaving.value) {
      return;
    }
    final GroupEntity? currentGroup = group.value;
    if (currentGroup == null) {
      appNavigator.showErrorSnackBar();
      return;
    }

    final String name = nameController.text.trim();
    final String activityName = activityNameController.text.trim();
    final int goal = int.tryParse(activityGoalController.text.trim()) ?? 0;
    if (name.isEmpty) {
      appNavigator.showErrorSnackBar(Get.context?.l10n.nameRequiredError);
      return;
    }
    if (activityName.isEmpty || goal <= 0) {
      appNavigator.showErrorSnackBar(
        Get.context?.l10n.createGroupActivityMissingError,
      );
      return;
    }

    isSaving.value = true;
    final Either<AppError, GroupEntity> result = await groupsRepository
        .updateGroup(
          group: currentGroup,
          name: name,
          description: descriptionController.text.trim(),
          activityPayload: _activityPayload(activityName, goal),
        );
    isSaving.value = false;

    result.fold(
      (error) => appNavigator.showErrorSnackBar(error.message),
      (updatedGroup) => appNavigator.back<GroupEntity>(result: updatedGroup),
    );
  }

  Map<String, dynamic> _activityPayload(String activityName, int goal) {
    if (isDailyGoalsTheme) {
      return {
        "name": activityName,
        "target_days": goal,
      };
    }

    final TimeCategoryType category = switch (theme) {
      GroupThemeType.reading => TimeCategoryType.reading,
      GroupThemeType.exercises => TimeCategoryType.exercises,
      GroupThemeType.hobbies => TimeCategoryType.hobbies,
      _ => TimeCategoryType.studying,
    };
    final int rest = int.tryParse(restController.text.trim()) ?? 0;
    final int sessions = int.tryParse(sessionsController.text.trim()) ?? 1;
    return {
      "name": activityName,
      "category": category.name,
      "goal_seconds": isReadingTheme ? 0 : goal * 60,
      "goal_pages": isReadingTheme ? goal : 0,
      "rest_minutes": rest <= 0 ? 1 : rest,
      "focus_session_count": sessions <= 0 ? 1 : sessions,
      "activity_type": "daily",
    };
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    activityNameController.dispose();
    activityGoalController.dispose();
    restController.dispose();
    sessionsController.dispose();
    super.onClose();
  }
}
