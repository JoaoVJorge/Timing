import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/update_daily_task_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/theme/subject_colors.dart";

class CreateTaskController extends GetxController {
  CreateTaskController({
    required this._addDailyTaskUseCase,
    required this._updateDailyTaskUseCase,
    required this._appNavigator,
    required this._achievementUnlockService,
    this._ensureNotificationsEnabled,
    this.editingTask,
    this.initialName,
  });

  static const List<int> targetDaysOptions = [5, 14, 30];
  static const int defaultReminderMinutes = 12 * 60;

  final AddDailyTaskUseCase _addDailyTaskUseCase;
  final UpdateDailyTaskUseCase _updateDailyTaskUseCase;
  final AppNavigator _appNavigator;
  final AchievementUnlockService _achievementUnlockService;

  /// Asks for the notifications permission when it is missing and tells
  /// whether reminders can be shown. Null where the app has no notifications
  /// at all, which leaves the reminder out of the form.
  final Future<bool> Function()? _ensureNotificationsEnabled;
  final DailyTaskEntity? editingTask;
  final String? initialName;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController customDaysController = TextEditingController(
    text: targetDaysOptions.first.toString(),
  );

  final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  final RxInt targetDays = targetDaysOptions.first.obs;
  final Rx<DailyTaskSequenceType> sequenceType =
      DailyTaskSequenceType.casual.obs;
  final RxBool reminderEnabled = false.obs;
  final RxInt reminderMinutes = defaultReminderMinutes.obs;
  final RxBool isSaving = false.obs;
  bool _hasInitializedThemeColor = false;
  bool _isEnablingReminder = false;

  bool get isEditing => editingTask != null;

  bool get supportsReminders => _ensureNotificationsEnabled != null;

  @override
  void onInit() {
    super.onInit();
    final DailyTaskEntity? task = editingTask;
    if (task == null) {
      final String normalizedInitialName = initialName?.trim() ?? "";
      if (normalizedInitialName.isNotEmpty) {
        nameController.text = normalizedInitialName;
      }
      return;
    }

    nameController.text = task.name;
    selectedColor.value = Color(task.colorValue);
    targetDays.value = task.targetDays;
    sequenceType.value = task.sequenceType;
    reminderEnabled.value = task.reminderMinutes != null;
    reminderMinutes.value = task.reminderMinutes ?? defaultReminderMinutes;
    customDaysController.text = task.targetDays > 0
        ? task.targetDays.toString()
        : "";
  }

  void initializeThemeColor(Color color) {
    if (_hasInitializedThemeColor || editingTask != null) {
      return;
    }
    selectedColor.value = SubjectColors.fromThemeAccent(color);
    _hasInitializedThemeColor = true;
  }

  void onSelectSequenceType(DailyTaskSequenceType type) {
    sequenceType.value = type;
  }

  void onSelectTargetDays(int days) {
    targetDays.value = days;
    customDaysController.clear();
  }

  void onCustomDaysChanged(String value) {
    final int? days = int.tryParse(value.trim());
    if (days != null && days > 0) {
      targetDays.value = days;
    }
  }

  Future<void> onToggleReminder(bool value) async {
    if (!value) {
      reminderEnabled.value = false;
      return;
    }
    final Future<bool> Function()? ensureNotificationsEnabled =
        _ensureNotificationsEnabled;
    if (ensureNotificationsEnabled == null || _isEnablingReminder) {
      return;
    }

    _isEnablingReminder = true;
    try {
      // A reminder that could never be shown must not look turned on.
      final bool allowed = await ensureNotificationsEnabled();
      if (isClosed) {
        return;
      }
      reminderEnabled.value = allowed;
      if (!allowed) {
        _appNavigator.showErrorSnackBar(
          Get.context?.l10n.goalReminderPermissionDenied,
        );
      }
    } finally {
      _isEnablingReminder = false;
    }
  }

  /// Choosing a time is also a way of asking for the reminder.
  Future<void> onPickReminderTime(int minutes) async {
    reminderMinutes.value = minutes;
    if (!reminderEnabled.value) {
      await onToggleReminder(true);
    }
  }

  Future<void> onSubmit() async {
    if (isSaving.value) {
      return;
    }

    final String name = nameController.text.trim();
    if (name.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.nameRequiredError);
      return;
    }
    final int normalizedTargetDays = targetDays.value;
    if (normalizedTargetDays < 0) {
      return;
    }

    isSaving.value = true;
    final DailyTaskEntity? task = editingTask;
    final int? reminder = reminderEnabled.value ? reminderMinutes.value : null;
    final Either<AppError, DailyTaskEntity> result = task == null
        ? await _addDailyTaskUseCase(
            name: name,
            colorValue: selectedColor.value.toARGB32(),
            targetDays: normalizedTargetDays,
            sequenceType: sequenceType.value,
            reminderMinutes: reminder,
          )
        : await _updateDailyTaskUseCase(
            task: task,
            name: name,
            colorValue: selectedColor.value.toARGB32(),
            targetDays: normalizedTargetDays,
            sequenceType: sequenceType.value,
            reminderMinutes: reminder,
          );
    isSaving.value = false;

    result.fold((error) => _appNavigator.showErrorSnackBar(), (task) {
      _achievementUnlockService.checkForNewUnlocks();
      _appNavigator.back<DailyTaskEntity>(result: task);
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    customDaysController.dispose();
    super.onClose();
  }
}
