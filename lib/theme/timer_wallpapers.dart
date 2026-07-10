import "package:flutter/material.dart";

class TimerWallpapers {
  const TimerWallpapers._();

  static const List<List<Color>> values = [
    [Color(0xFF000000), Color(0xFF1C1C28)],
    [Color(0xFF0F2027), Color(0xFF2C5364)],
    [Color(0xFF1F1C2C), Color(0xFF4A4368)],
    [Color(0xFF141E30), Color(0xFF243B55)],
    [Color(0xFF2D1B4E), Color(0xFF16121F)],
    [Color(0xFF1A2F1A), Color(0xFF0E1A12)],
  ];

  static LinearGradient byIndex(int index) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: values[index % values.length],
  );
}
