import "package:flutter/material.dart";
import "package:help_out/theme/colors.dart";

abstract class AppThemes {
  static ThemeData build({required Color seed, required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;
    final AppColorTokens tokens = AppColorTokens.fromSeed(seed: seed, isDark: isDark);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: tokens.scaffold,
      dialogTheme: DialogThemeData(backgroundColor: tokens.surface),
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      extensions: [tokens],
      fontFamily: "Roboto",
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tokens.textHint),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tokens.textBody),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surface,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.iconDisabled,
      ),
    );
  }
}
