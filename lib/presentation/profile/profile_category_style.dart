import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

/// Per-category accent colors used to differentiate the profile stat cards.
/// Kept local to the profile feature so the global theme stays primary-based;
/// only the small tinted icon badges use these hues, the text stays neutral.
extension ProfileCategoryStyleX on TimeCategoryType {
  Color get accentColor => switch (this) {
    TimeCategoryType.studying => const Color(0xFF6C5CE7),
    TimeCategoryType.exercises => const Color(0xFF27AE60),
    TimeCategoryType.reading => const Color(0xFFE8862E),
    TimeCategoryType.hobbies => const Color(0xFFEC4899),
  };
}
