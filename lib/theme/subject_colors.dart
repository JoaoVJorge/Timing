import "package:flutter/material.dart";
import "package:timing/theme/accent_presets.dart";

class SubjectColors {
  const SubjectColors._();

  static const List<Color> values = AppAccentPresets.values;

  static const List<Color> darkValues = [
    Color(0xFF8FCBFF), // Azul
    Color(0xFFD6A8F2), // Roxo
    Color(0xFFC5EA67), // Verde oliva
    Color(0xFFFF9DCA), // Rosa
    Color(0xFF66E3EC), // Ciano
    Color(0xFFFFD84D), // Amarelo
    Color(0xFFFFBE64), // Laranja
  ];

  static Color byIndex(int index) => values[index % values.length];

  static Color normalize(Color color) {
    Color closest = values.first;
    double closestDistance = double.infinity;
    for (final Color value in [...values, ...darkValues]) {
      final double distance = _colorDistance(value, color);
      if (distance < closestDistance) {
        final int index = [...values, ...darkValues].indexOf(value);
        closest = index < values.length ? value : values[index - values.length];
        closestDistance = distance;
      }
    }
    return closest;
  }

  static Color resolveForTheme(Color color, {required bool isDark}) {
    final Color normalized = normalize(color);
    if (!isDark) {
      return normalized;
    }
    final int index = values.indexWhere(
      (value) => value.toARGB32() == normalized.toARGB32(),
    );
    return index == -1 ? normalized : darkValues[index];
  }

  static Color fromThemeAccent(Color accent) {
    return normalize(accent);
  }

  static double _colorDistance(Color a, Color b) {
    final double red = a.r - b.r;
    final double green = a.g - b.g;
    final double blue = a.b - b.b;
    return red * red + green * green + blue * blue;
  }
}
