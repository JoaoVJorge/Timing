import "package:flutter/material.dart";

class AppAccentPresets {
  const AppAccentPresets._();

  static const List<Color> values = [
    Color(0xFF1976D2), // Azul
    Color(0xFF8E44AD), // Roxo
    Color(0xFF6B8E23), // Verde oliva
    Color(0xFFFF1493), // Rosa
    Color(0xFF0AACC2), // Ciano
    Color(0xFFEBAD03), // Amarelo
    Color(0xFFFF8C00), // Laranja
  ];

  static Color get defaultAccent => values.first;
}
