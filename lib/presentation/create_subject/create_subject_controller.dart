import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_use_case.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";

class CreateSubjectController extends GetxController {
  CreateSubjectController({
    required this._addSubjectUseCase,
    required this._updateSubjectUseCase,
    required this._appNavigator,
    required this.category,
    this.editingSubject,
  });

  final AddSubjectUseCase _addSubjectUseCase;
  final UpdateSubjectUseCase _updateSubjectUseCase;
  final AppNavigator _appNavigator;

  final TimeCategoryType category;
  final SubjectEntity? editingSubject;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController restMinutesController = TextEditingController(
    text: SubjectEntity.defaultRestMinutes.toString(),
  );
  final TextEditingController focusSessionCountController =
      TextEditingController(text: "1");

  late final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  late final RxString selectedIconName = SubjectIcons.suggestionsFor(
    category,
  ).first.obs;

  bool _hasInitializedThemeColor = false;

  final RxInt restMinutes = SubjectEntity.defaultRestMinutes.obs;
  final RxInt focusSessionCount = 1.obs;
  final RxInt wallpaperIndex = 0.obs;
  final RxBool isSaving = false.obs;
  final RxString name = "".obs;
  final RxString goal = "".obs;

  final List<int> restMinutesOptions = [5, 10, 15, 20];
  final List<int> focusSessionCountOptions = [1, 2, 3, 4];
  final List<int> timeGoalPresets = [15, 25, 30, 45];
  final List<int> pageGoalPresets = [5, 10, 25, 50];

  bool get isPageBased => category == TimeCategoryType.reading;
  bool get isEditing => editingSubject != null;

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

  void initializeThemeColor(Color color) {
    if (_hasInitializedThemeColor) {
      return;
    }
    if (editingSubject != null) {
      selectedColor.value = Color(editingSubject!.colorValue);
      _hasInitializedThemeColor = true;
      return;
    }
    selectedColor.value = SubjectColors.fromThemeAccent(color);
    _hasInitializedThemeColor = true;
  }

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

  String submitLabel(BuildContext context) {
    if (isEditing) {
      return switch (context.languageCode) {
        "en" => "Save changes",
        "es" => "Guardar cambios",
        "fr" => "Enregistrer",
        "de" => "Änderungen speichern",
        "ar" => "حفظ التغييرات",
        _ => "Salvar alterações",
      };
    }

    return switch (category) {
      TimeCategoryType.studying => context.l10n.createSubjectButtonStudying,
      TimeCategoryType.reading => context.l10n.createSubjectButtonReading,
      TimeCategoryType.exercises => context.l10n.createSubjectButtonExercises,
      TimeCategoryType.hobbies => context.l10n.createSubjectButtonHobbies,
    };
  }

  String successMessage(BuildContext context) {
    if (isEditing) {
      return switch (context.languageCode) {
        "en" => "Updated successfully",
        "es" => "Actualizado correctamente",
        "fr" => "Mis à jour",
        "de" => "Erfolgreich aktualisiert",
        "ar" => "تم التحديث بنجاح",
        _ => "Atualizado com sucesso",
      };
    }

    return switch (category) {
      TimeCategoryType.studying => context.l10n.createSubjectSuccessStudying,
      TimeCategoryType.reading => context.l10n.createSubjectSuccessReading,
      TimeCategoryType.exercises => context.l10n.createSubjectSuccessExercises,
      TimeCategoryType.hobbies => context.l10n.createSubjectSuccessHobbies,
    };
  }

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
      return context.l10n.createSubjectPagesValue(int.parse(goal.value.trim()));
    }

    final int minutes = int.parse(goal.value.trim());
    final int seconds = minutes * 60;
    final int wholeHours = seconds ~/ 3600;
    final int remainingMinutes = (seconds % 3600) ~/ 60;
    if (remainingMinutes == 0 && wholeHours > 0) {
      return context.l10n.createSubjectHoursValue(wholeHours);
    }
    if (wholeHours == 0) {
      return context.l10n.restMinutesChip(minutes);
    }
    return context.l10n.createSubjectHoursMinutesValue(
      wholeHours,
      remainingMinutes,
    );
  }

  void setGoalPreset(int value) {
    goalController.text = value.toString();
    goal.value = goalController.text;
  }

  void setRestMinutes(int minutes) {
    restMinutes.value = minutes;
    restMinutesController.text = minutes.toString();
  }

  void setFocusSessionCount(int count) {
    focusSessionCount.value = count;
    focusSessionCountController.text = count.toString();
  }

  @override
  void onInit() {
    super.onInit();
    final SubjectEntity? subject = editingSubject;
    if (subject != null) {
      nameController.text = subject.name;
      selectedColor.value = Color(subject.colorValue);
      selectedIconName.value = subject.iconName.isEmpty
          ? SubjectIcons.suggestionsFor(category).first
          : subject.iconName;
      restMinutes.value = subject.restMinutes;
      restMinutesController.text = subject.restMinutes.toString();
      focusSessionCount.value = subject.focusSessionCount;
      focusSessionCountController.text = subject.focusSessionCount.toString();
      wallpaperIndex.value = subject.wallpaperIndex;
      goalController.text = isPageBased
          ? subject.goalPages.toString()
          : (subject.goalSeconds ~/ 60).toString();
      goal.value = goalController.text;
      name.value = nameController.text;
    } else if (!isPageBased && goalController.text.trim().isEmpty) {
      goalController.text = "25";
      goal.value = goalController.text;
    }
    nameController.addListener(() => name.value = nameController.text);
    goalController.addListener(() => goal.value = goalController.text);
    restMinutesController.addListener(() {
      final int? minutes = int.tryParse(restMinutesController.text.trim());
      if (minutes != null && minutes > 0) {
        restMinutes.value = minutes;
      }
    });
    focusSessionCountController.addListener(() {
      final int? count = int.tryParse(focusSessionCountController.text.trim());
      if (count != null && count > 0) {
        focusSessionCount.value = count;
      }
    });
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
      final int goalMinutes = int.tryParse(goalController.text.trim()) ?? 0;
      goalSeconds = goalMinutes * 60;
    }

    final SubjectEntity? subject = editingSubject;
    final Either<AppError, SubjectEntity> result = subject == null
        ? await _addSubjectUseCase(
            name: name,
            category: category,
            colorValue: selectedColor.value.toARGB32(),
            goalSeconds: goalSeconds,
            goalPages: goalPages,
            iconName: selectedIconName.value,
            restMinutes: restMinutes.value,
            focusSessionCount: focusSessionCount.value,
            wallpaperIndex: wallpaperIndex.value,
          )
        : await _updateSubjectUseCase(
            subjectId: subject.id,
            name: name,
            colorValue: selectedColor.value.toARGB32(),
            goalSeconds: goalSeconds,
            goalPages: goalPages,
            iconName: selectedIconName.value,
            restMinutes: restMinutes.value,
            focusSessionCount: focusSessionCount.value,
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
    restMinutesController.dispose();
    focusSessionCountController.dispose();
    super.onClose();
  }
}
