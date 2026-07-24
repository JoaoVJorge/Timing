import "package:flutter/material.dart";
import "package:help_out/theme/accent_presets.dart";

class SubjectColors {
  const SubjectColors._();

  static const List<Color> values = [
    ...AppAccentPresets.values,
    Color(0xFFCDE4F9),
    Color(0xFFEADCF5),
    Color(0xFFDEF0B4),
    Color(0xFFF6D6E7),
    Color(0xFFB9F0F5),
    Color(0xFFFBEBAA),
    Color(0xFFFFE2B3),
  ];

  static Color byIndex(int index) => values[index % values.length];

  static Color fromThemeAccent(Color accent) => accent;
}
