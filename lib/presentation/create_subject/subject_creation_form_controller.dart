import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

abstract class SubjectCreationFormController {
  TimeCategoryType get category;
  TextEditingController get nameController;
  TextEditingController get goalController;
  Rx<Color> get selectedColor;
  RxString get selectedIconName;
  RxInt get restMinutes;
  RxInt get focusSessionCount;
  RxInt get wallpaperIndex;
  Rx<SubjectActivityType> get activityType;
  RxString get goal;
  List<int> get restMinutesOptions;
  List<int> get focusSessionCountOptions;
  List<int> get timeGoalPresets;
  List<int> get pageGoalPresets;
  bool get isPageBased;
  List<String> get iconSuggestions;

  String title(BuildContext context);
  String subtitle(BuildContext context);
  String nameHint(BuildContext context);
  void initializeThemeColor(Color color);
  void setActivityType(SubjectActivityType type);
  void setGoalPreset(int value);
  void setRestMinutes(int minutes);
  void setFocusSessionCount(int count);
}
