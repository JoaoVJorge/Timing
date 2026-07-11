import "package:flutter/material.dart";

class SubjectColors {
  const SubjectColors._();

  static const List<Color> values = [
    Color(0xFFFFC107),
    Color(0xFFFF8A50),
    Color(0xFF8325FF),
    Color(0xFF2E6ADE),
    Color(0xFF22C55E),
    Color(0xFFE0507A),
    Color(0xFF1FA2A6),
  ];

  static Color byIndex(int index) => values[index % values.length];
}
