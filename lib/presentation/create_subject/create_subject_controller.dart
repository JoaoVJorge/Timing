import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_subject_use_case.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";

class CreateSubjectController extends GetxController {
  CreateSubjectController({
    required this._addSubjectUseCase,
    required this._appNavigator,
    required this.category,
  });

  final AddSubjectUseCase _addSubjectUseCase;
  final AppNavigator _appNavigator;

  final TimeCategoryType category;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  late final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  late final RxString selectedIconName = SubjectIcons.suggestionsFor(
    category,
  ).first.obs;

  final RxInt restMinutes = SubjectEntity.defaultRestMinutes.obs;
  final RxInt wallpaperIndex = 0.obs;
  final RxBool isSaving = false.obs;
  final RxString name = "".obs;
  final RxString goal = "".obs;

  final List<int> restMinutesOptions = [5, 10, 15, 20];
  final List<num> timeGoalPresets = [1, 3, 5, 10];
  final List<num> pageGoalPresets = [5, 10, 25, 50];

  bool get isPageBased => category == TimeCategoryType.reading;

  List<String> get iconSuggestions => SubjectIcons.suggestionsFor(category);

  bool get hasValidGoal {
    final String rawGoal = goal.value.trim().replaceAll(",", ".");
    if (rawGoal.isEmpty) {
      return false;
    }

    if (isPageBased) {
      return (int.tryParse(rawGoal) ?? 0) > 0;
    }

    return (double.tryParse(rawGoal) ?? 0) > 0;
  }

  bool get canSubmit => name.value.trim().isNotEmpty && hasValidGoal;

  String title(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectTitleStudying,
    TimeCategoryType.reading => context.l10n.createSubjectTitleReading,
    TimeCategoryType.exercises => context.l10n.createSubjectTitleExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectTitleHobbies,
  };

  String subtitle(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectSubtitleStudying,
    TimeCategoryType.reading => context.l10n.createSubjectSubtitleReading,
    TimeCategoryType.exercises => context.l10n.createSubjectSubtitleExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectSubtitleHobbies,
  };

  String nameLabel(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectNameLabelStudying,
    TimeCategoryType.reading => context.l10n.createSubjectNameLabelReading,
    TimeCategoryType.exercises => context.l10n.createSubjectNameLabelExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectNameLabelHobbies,
  };

  String nameHint(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectNameHintStudying,
    TimeCategoryType.reading => context.l10n.createSubjectNameHintReading,
    TimeCategoryType.exercises => context.l10n.createSubjectNameHintExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectNameHintHobbies,
  };

  String submitLabel(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectButtonStudying,
    TimeCategoryType.reading => context.l10n.createSubjectButtonReading,
    TimeCategoryType.exercises => context.l10n.createSubjectButtonExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectButtonHobbies,
  };

  String successMessage(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectSuccessStudying,
    TimeCategoryType.reading => context.l10n.createSubjectSuccessReading,
    TimeCategoryType.exercises => context.l10n.createSubjectSuccessExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectSuccessHobbies,
  };

  String? missingRequirement(BuildContext context) {
    if (name.value.trim().isEmpty) {
      return context.l10n.createSubjectMissingName;
    }
    if (!hasValidGoal) {
      return isPageBased
          ? context.l10n.createSubjectMissingPagesGoal
          : context.l10n.createSubjectMissingTimeGoal;
    }
    return null;
  }

  String previewName(BuildContext context) {
    final String value = name.value.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return nameLabel(context);
  }

  String previewGoal(BuildContext context) {
    if (!hasValidGoal) {
      return context.l10n.createSubjectPreviewNoGoal;
    }

    if (isPageBased) {
      return context.l10n.metricPagesValue(int.parse(goal.value.trim()));
    }

    final double hours = double.parse(goal.value.trim().replaceAll(",", "."));
    final int seconds = (hours * 3600).round();
    final int wholeHours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    if (minutes == 0) {
      return context.l10n.createSubjectHoursValue(wholeHours);
    }
    return context.l10n.createSubjectHoursMinutesValue(wholeHours, minutes);
  }

  void setGoalPreset(num value) {
    goalController.text = isPageBased ? value.toInt().toString() : "$value";
    goal.value = goalController.text;
  }

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => name.value = nameController.text);
    goalController.addListener(() => goal.value = goalController.text);
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
    if (!hasValidGoal) {
      _appNavigator.showErrorSnackBar(missingRequirement(Get.context!)!);
      return;
    }

    isSaving.value = true;

    int goalSeconds = 0;
    int goalPages = 0;
    if (isPageBased) {
      goalPages = int.tryParse(goalController.text.trim()) ?? 0;
    } else {
      final double goalHours =
          double.tryParse(goalController.text.trim().replaceAll(",", ".")) ?? 0;
      goalSeconds = (goalHours * 3600).round();
    }

    final Either<AppError, SubjectEntity> result = await _addSubjectUseCase(
      name: name,
      category: category,
      colorValue: selectedColor.value.toARGB32(),
      goalSeconds: goalSeconds,
      goalPages: goalPages,
      iconName: selectedIconName.value,
      restMinutes: restMinutes.value,
      wallpaperIndex: wallpaperIndex.value,
    );

    isSaving.value = false;
    result.fold((error) => _appNavigator.showErrorSnackBar(), (subject) {
      final String message = successMessage(Get.context!);
      _appNavigator.back<SubjectEntity>(result: subject);
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (Get.context != null) {
          _appNavigator.showSuccessSnackBar(message);
        }
      });
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    goalController.dispose();
    super.onClose();
  }
}
