import "package:flutter/material.dart";

class AppAccentPresets {
  const AppAccentPresets._();

  static const List<Color> values = [
    Color(0xFFFF7A30),
    Color(0xFFFFC107),
    Color(0xFF8325FF),
    Color(0xFF2E6ADE),
    Color(0xFF3FA65D),
    Color(0xFFE0507A),
    Color(0xFF1FA2A6),
  ];

  static Color get defaultAccent => values.first;
}
