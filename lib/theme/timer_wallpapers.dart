import "package:flutter/material.dart";

class TimerWallpapers {
  const TimerWallpapers._();

  static const List<List<Color>> values = [
    // Branco suave em três tons
    [Color(0xFFFFFFFF), Color(0xFFF5F5F5), Color(0xFFE2E2E2)],

    // Branco predominante com queda perolada
    [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFD8DCE2)],

    // Prata de alto contraste em três tons
    [Color(0xFFFAFAFA), Color(0xFFD0D0D0), Color(0xFFA0A0A0)],

    // Preto profundo
    [Color(0xFF3C3C3C), Color(0xFF050505)],

    // Grafite metálico
    [Color(0xFF464A4F), Color(0xFF17191C)],

    // Azul cobalto
    [Color(0xFF123B87), Color(0xFF071630)],

    // Magenta profundo
    [Color(0xFF7B1E62), Color(0xFF2B0B25)],

    // Verde esmeralda
    [Color(0xFF075039), Color(0xFF06281E)],
  ];

  static const List<List<double>?> _stops = [
    [0, 0.48, 1],
    [0, 0.62, 1],
    [0, 0.52, 1],
    null,
    null,
    null,
    null,
    null,
  ];

  static const List<Alignment> _begins = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.centerLeft,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.topLeft,
    Alignment.centerLeft,
    Alignment.topCenter,
  ];

  static const List<Alignment> _ends = [
    Alignment.bottomRight,
    Alignment.bottomCenter,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.topRight,
    Alignment.bottomRight,
    Alignment.centerRight,
    Alignment.bottomCenter,
  ];

  static bool usesDarkForeground(int index) => _normalizedIndex(index) < 3;

  static LinearGradient byIndex(int index) {
    final int normalizedIndex = _normalizedIndex(index);
    return LinearGradient(
      begin: _begins[normalizedIndex],
      end: _ends[normalizedIndex],
      colors: values[normalizedIndex],
      stops: _stops[normalizedIndex],
    );
  }

  static int _normalizedIndex(int index) => index % values.length;
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
