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

  static const List<int> restMinutesOptions = [5, 10, 15, 20];

  final AddSubjectUseCase _addSubjectUseCase;
  final AppNavigator _appNavigator;

  final TimeCategoryType category;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController musicController = TextEditingController();

  late final Rx<Color> selectedColor = SubjectColors.values.first.obs;
  late final RxString selectedIconName = SubjectIcons.suggestionsFor(
    category,
  ).first.obs;
  final RxInt restMinutes = SubjectEntity.defaultRestMinutes.obs;
  final RxInt wallpaperIndex = 0.obs;
  final RxBool isSaving = false.obs;

  bool get isPageBased => category == TimeCategoryType.reading;

  List<String> get iconSuggestions => SubjectIcons.suggestionsFor(category);

  Future<void> onSubmit() async {
    if (isSaving.value) {
      return;
    }

    final String name = nameController.text.trim();
    if (name.isEmpty) {
      _appNavigator.showErrorSnackBar(Get.context!.l10n.nameRequiredError);
      return;
    }

    isSaving.value = true;

    int goalSeconds = 0;
    int goalPages = 0;
    if (isPageBased) {
      goalPages = int.tryParse(goalController.text.trim()) ?? 0;
    } else {
      final double goalHours =
          double.tryParse(goalController.text.trim()) ?? 0;
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
      musicSuggestion: musicController.text.trim(),
      wallpaperIndex: wallpaperIndex.value,
    );

    isSaving.value = false;
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (subject) => _appNavigator.back<SubjectEntity>(result: subject),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    goalController.dispose();
    musicController.dispose();
    super.onClose();
  }
}
