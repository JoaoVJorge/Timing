import "package:flutter/material.dart";
import "package:help_out/theme/accent_presets.dart";

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

  static const List<Color> _themeMatches = [
    Color(0xFF2E6ADE), // Azul
    Color(0xFF8325FF), // Roxo
    Color(0xFF22C55E), // Verde
    Color(0xFFE0507A), // Rosa
    Color(0xFF1FA2A6), // Ciano
    Color(0xFFFFC107), // Amarelo
    Color(0xFFFF8A50), // Laranja
  ];

  static Color byIndex(int index) => values[index % values.length];

  static Color fromThemeAccent(Color accent) {
    final HSLColor source = HSLColor.fromColor(accent);
    int bestIndex = 0;
    double bestScore = double.infinity;

    for (int index = 0; index < AppAccentPresets.values.length; index++) {
      final HSLColor candidate = HSLColor.fromColor(
        AppAccentPresets.values[index],
      );
      final double hueDifference = (source.hue - candidate.hue).abs();
      final double hueDistance = hueDifference > 180
          ? 360 - hueDifference
          : hueDifference;
      final double score =
          hueDistance +
          (source.saturation - candidate.saturation).abs() * 16 +
          (source.lightness - candidate.lightness).abs() * 8;

      if (score < bestScore) {
        bestScore = score;
        bestIndex = index;
      }
    }

    return _themeMatches[bestIndex];
  }
}
