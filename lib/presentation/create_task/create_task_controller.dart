import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:help_out/theme/subject_colors.dart";

class CreateTaskController extends GetxController {
  CreateTaskController({
    required this._addDailyTaskUseCase,
    required this._appNavigator,
  });

  static const List<int> targetDaysOptions = [3, 5, 7, 14, 21, 30];

  final AddDailyTaskUseCase _addDailyTaskUseCase;
  final AppNavigator _appNavigator;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController customDaysController = TextEditingController();

  final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  final RxInt targetDays = targetDaysOptions.first.obs;
  final RxBool isSaving = false.obs;

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
    final String name = nameController.text.trim();
    if (name.isEmpty || targetDays.value <= 0 || isSaving.value) {
      return;
    }

    isSaving.value = true;
    final Either<AppError, DailyTaskEntity> result = await _addDailyTaskUseCase(
      name: name,
      colorValue: selectedColor.value.toARGB32(),
      targetDays: targetDays.value,
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
