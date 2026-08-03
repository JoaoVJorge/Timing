import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/theme/accent_presets.dart";

/// Per-category accent colors used to differentiate the progress stat cards.
/// Kept local to the progress feature so the global theme stays primary-based;
/// only the small tinted icon badges use these hues, the text stays neutral.
extension ProgressCategoryStyleX on TimeCategoryType {
  Color get accentColor => switch (this) {
    TimeCategoryType.studying => ProgressAccentColors.purple,
    TimeCategoryType.exercises => ProgressAccentColors.green,
    TimeCategoryType.reading => ProgressAccentColors.orange,
    TimeCategoryType.hobbies => ProgressAccentColors.pink,
  };
}

class ProgressAccentColors {
  const ProgressAccentColors._();

  static Color get blue => AppAccentPresets.values[0];
  static Color get purple => AppAccentPresets.values[1];
  static Color get green => AppAccentPresets.values[2];
  static Color get pink => AppAccentPresets.values[3];
  static Color get orange => AppAccentPresets.values[6];
}
