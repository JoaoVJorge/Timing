import "package:flutter/material.dart";

class TimerWallpapers {
  const TimerWallpapers._();

  static const List<List<Color>> values = [
    // Cinza claro e neutro
    [Color(0xFF3A3B3F), Color(0xFF1C1D21)],

    // Cinza levemente azulado
    [Color(0xFF3D4148), Color(0xFF202329)],

    // Cinza suave
    [Color(0xFF45464B), Color(0xFF24252A)],

    // Grafite claro
    [Color(0xFF4A4C52), Color(0xFF27292E)],

    // Cinza com toque frio
    [Color(0xFF404751), Color(0xFF21262D)],

    // Cinza com toque roxo muito discreto
    [Color(0xFF45424F), Color(0xFF25232B)],

    // Cinza quente
    [Color(0xFF484541), Color(0xFF292725)],

    // Cinza esverdeado bem sutil
    [Color(0xFF414944), Color(0xFF222824)],
  ];

  static LinearGradient byIndex(int index) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: values[index % values.length],
  );
}

class TimerRestPalette {
  const TimerRestPalette._();

  static const Color accent = Color(0xFFA879FF);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF07163E), Color(0xFF050C27), Color(0xFF020613)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> ringGradientColors = [
    Color(0xFF653CC9),
    Color(0xFFB986FF),
    Color(0xFF8F5CFF),
  ];
}
