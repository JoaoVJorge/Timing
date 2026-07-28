import "package:flutter/material.dart";
import "package:help_out/theme/accent_presets.dart";

class SubjectColors {
  const SubjectColors._();

  static const List<Color> values = [
    ...AppAccentPresets.values,
    Color(0xFF8FCBFF),
    Color(0xFFD6A8F2),
    Color(0xFFC5EA67),
    Color(0xFFFF9DCA),
    Color(0xFF66E3EC),
    Color(0xFFFFD84D),
    Color(0xFFFFBE64),
  ];

  static Color byIndex(int index) => values[index % values.length];

  static Color fromThemeAccent(Color accent) => accent;
}
