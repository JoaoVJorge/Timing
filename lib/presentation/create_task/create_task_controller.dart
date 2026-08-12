import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:help_out/core/domain/use_cases/update_daily_task_use_case.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/subject_colors.dart";

class CreateTaskController extends GetxController {
  CreateTaskController({
    required this._addDailyTaskUseCase,
    required this._updateDailyTaskUseCase,
    required this._appNavigator,
    this.editingTask,
  });

  static const List<int> targetDaysOptions = [5, 14, 30];

  final AddDailyTaskUseCase _addDailyTaskUseCase;
  final UpdateDailyTaskUseCase _updateDailyTaskUseCase;
  final AppNavigator _appNavigator;
  final DailyTaskEntity? editingTask;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController customDaysController = TextEditingController();

  final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  final RxInt targetDays = targetDaysOptions.first.obs;
  final Rx<DailyTaskSequenceType> sequenceType =
      DailyTaskSequenceType.casual.obs;
  final RxBool isSaving = false.obs;
  bool _hasInitializedThemeColor = false;

  bool get isEditing => editingTask != null;

  @override
  void onInit() {
    super.onInit();
    final DailyTaskEntity? task = editingTask;
    if (task == null) {
      return;
    }

    nameController.text = task.name;
    selectedColor.value = Color(task.colorValue);
    targetDays.value = task.targetDays;
    sequenceType.value = task.sequenceType;
    if (!targetDaysOptions.contains(task.targetDays) && task.targetDays > 0) {
      customDaysController.text = task.targetDays.toString();
    }
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
    final Either<AppError, DailyTaskEntity> result = task == null
        ? await _addDailyTaskUseCase(
            name: name,
            colorValue: selectedColor.value.toARGB32(),
            targetDays: normalizedTargetDays,
            sequenceType: sequenceType.value,
          )
        : await _updateDailyTaskUseCase(
            task: task,
            name: name,
            colorValue: selectedColor.value.toARGB32(),
            targetDays: normalizedTargetDays,
            sequenceType: sequenceType.value,
          );
    isSaving.value = false;

    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (task) => _appNavigator.back<DailyTaskEntity>(result: task),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    customDaysController.dispose();
    super.onClose();
  }
}
