import "package:flutter/material.dart";
import "package:timing/theme/colors.dart";

abstract class AppThemes {
  static (int, Brightness)? _cacheKey;
  static ThemeData? _cachedTheme;

  /// [GetMaterialApp] is rebuilt inside an [Obx], so this runs on every accent /
  /// brightness / locale change. Building a [ThemeData] (notably
  /// [ColorScheme.fromSeed]) is expensive, so the last result is reused whenever
  /// the seed and brightness are unchanged.
  static ThemeData build({
    required Color seed,
    required Brightness brightness,
  }) {
    final (int, Brightness) key = (seed.toARGB32(), brightness);
    if (_cacheKey == key && _cachedTheme != null) {
      return _cachedTheme!;
    }

    final ThemeData theme = _build(seed: seed, brightness: brightness);
    _cacheKey = key;
    _cachedTheme = theme;
    return theme;
  }

  static ThemeData _build({
    required Color seed,
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final AppColorTokens tokens = AppColorTokens.fromSeed(
      seed: seed,
      isDark: isDark,
    );

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: tokens.scaffold,
      dialogTheme: DialogThemeData(backgroundColor: tokens.surface),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      extensions: [tokens],
      fontFamily: "Nunito",
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: tokens.textHint,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: tokens.textBody,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surface,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.iconDisabled,
      ),
    );
  }
}
