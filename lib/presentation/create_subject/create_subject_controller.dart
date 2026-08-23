import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_subject_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/analytics/analytics_event.dart";
import "package:timing/core/services/analytics/analytics_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/create_subject/subject_creation_form_controller.dart";
import "package:timing/theme/subject_colors.dart";
import "package:timing/theme/subject_icons.dart";

class CreateSubjectController extends GetxController
    implements SubjectCreationFormController {
  CreateSubjectController({
    required this._addSubjectUseCase,
    required this._updateSubjectUseCase,
    required this._appNavigator,
    required this._achievementUnlockService,
    required this._analyticsService,
    required this.category,
    this.editingSubject,
    this.initialName,
  });

  final AddSubjectUseCase _addSubjectUseCase;
  final UpdateSubjectUseCase _updateSubjectUseCase;
  final AppNavigator _appNavigator;
  final AchievementUnlockService _achievementUnlockService;
  final AnalyticsService _analyticsService;

  @override
  final TimeCategoryType category;
  final SubjectEntity? editingSubject;
  final String? initialName;

  @override
  final TextEditingController nameController = TextEditingController();
  @override
  final TextEditingController goalController = TextEditingController();
  @override
  final TextEditingController restMinutesController = TextEditingController();
  final TextEditingController focusSessionCountController =
      TextEditingController(text: "1");

  @override
  late final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  @override
  late final RxString selectedIconName = SubjectIcons.suggestionsFor(
    category,
  ).first.obs;

  bool _hasInitializedThemeColor = false;

  @override
  late final RxInt restMinutes = _defaultRestValue.obs;
  @override
  final RxInt focusSessionCount = 1.obs;
  @override
  final RxInt wallpaperIndex = 0.obs;
  @override
  final Rx<SubjectActivityType> activityType = SubjectActivityType.daily.obs;
  final RxBool isSaving = false.obs;
  final RxString name = "".obs;
  @override
  final RxString goal = "".obs;

  @override
  List<int> get restMinutesOptions =>
      category == TimeCategoryType.exercises ? [30, 60, 90] : [5, 10, 15];
  @override
  final List<int> focusSessionCountOptions = [1, 2, 3];
  @override
  final List<int> timeGoalPresets = [15, 30, 60];
  @override
  final List<int> totalTimeGoalPresets = [1, 2, 3, 4];
  @override
  final List<int> pageGoalPresets = [5, 10, 25, 50];

  @override
  bool get isPageBased => category == TimeCategoryType.reading;
  bool get isEditing => editingSubject != null;
  int get _defaultRestValue => category == TimeCategoryType.exercises
      ? SubjectEntity.defaultRestSeconds
      : SubjectEntity.defaultRestMinutes;

  @override
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

  @override
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

  String nameLabel(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectNameLabelStudying,
    TimeCategoryType.reading => context.l10n.createSubjectNameLabelReading,
    TimeCategoryType.exercises => context.l10n.createSubjectNameLabelExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectNameLabelHobbies,
  };

  @override
  String nameHint(BuildContext context) => switch (category) {
    TimeCategoryType.studying => context.l10n.createSubjectNameHintStudying,
    TimeCategoryType.reading => context.l10n.createSubjectNameHintReading,
    TimeCategoryType.exercises => context.l10n.createSubjectNameHintExercises,
    TimeCategoryType.hobbies => context.l10n.createSubjectNameHintHobbies,
  };

  String submitLabel(BuildContext context) {
    if (isEditing) {
      return context.l10n.saveChangesButton;
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
      return context.l10n.updatedSuccessfullyMessage;
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

  @override
  void setGoalPreset(int value) {
    goalController.text = value.toString();
    goal.value = goalController.text;
  }

  @override
  void setRestMinutes(int minutes) {
    restMinutes.value = minutes;
    restMinutesController.text = minutes.toString();
  }

  @override
  void setFocusSessionCount(int count) {
    focusSessionCount.value = count;
    focusSessionCountController.text = count.toString();
  }

  @override
  void setActivityType(SubjectActivityType type) {
    activityType.value = type;
    if (type == SubjectActivityType.permanent) {
      setFocusSessionCount(1);
      setGoalPreset(1);
    } else if (!isPageBased) {
      setGoalPreset(30);
    }
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
      restMinutes.value = category == TimeCategoryType.exercises
          ? subject.restSeconds
          : subject.restMinutes > 0
          ? subject.restMinutes
          : SubjectEntity.defaultRestMinutes;
      restMinutesController.text = restMinutes.value.toString();
      focusSessionCount.value = subject.focusSessionCount;
      focusSessionCountController.text = subject.focusSessionCount.toString();
      wallpaperIndex.value = subject.wallpaperIndex;
      activityType.value = subject.activityType;
      goalController.text = isPageBased
          ? subject.goalPages.toString()
          : subject.activityType == SubjectActivityType.permanent
          ? (subject.goalSeconds ~/ 3600).toString()
          : (subject.goalSeconds ~/ 60).toString();
      goal.value = goalController.text;
      name.value = nameController.text;
    } else {
      final String normalizedInitialName = initialName?.trim() ?? "";
      if (normalizedInitialName.isNotEmpty) {
        nameController.text = normalizedInitialName;
        name.value = normalizedInitialName;
      }
      if (!isPageBased && goalController.text.trim().isEmpty) {
        goalController.text = "30";
        goal.value = goalController.text;
      }
      restMinutes.value = _defaultRestValue;
      restMinutesController.text = _defaultRestValue.toString();
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
      final int goalValue = int.tryParse(goalController.text.trim()) ?? 0;
      goalSeconds = activityType.value == SubjectActivityType.permanent
          ? goalValue * 3600
          : goalValue * 60;
    }

    final int normalizedFocusSessionCount =
        isPageBased || activityType.value == SubjectActivityType.permanent
        ? 1
        : focusSessionCount.value;
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
            focusSessionCount: normalizedFocusSessionCount,
            wallpaperIndex: wallpaperIndex.value,
            activityType: activityType.value,
          )
        : await _updateSubjectUseCase(
            subjectId: subject.id,
            name: name,
            colorValue: selectedColor.value.toARGB32(),
            goalSeconds: goalSeconds,
            goalPages: goalPages,
            iconName: selectedIconName.value,
            restMinutes: restMinutes.value,
            focusSessionCount: normalizedFocusSessionCount,
            wallpaperIndex: wallpaperIndex.value,
            activityType: activityType.value,
          );

    isSaving.value = false;
    result.fold((error) => _appNavigator.showErrorSnackBar(), (subject) {
      final String message = successMessage(Get.context!);
      if (!isEditing) {
        _analyticsService.track(
          AnalyticsEvent.subjectCreated(category: category),
        );
      }
      _achievementUnlockService.checkForNewUnlocks();
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
