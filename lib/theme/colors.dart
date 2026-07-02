import "package:flutter/material.dart";

class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.primary,
    required this.primaryPastel,
    required this.primaryVeryLight,
    required this.linkColor,
    required this.primaryForeground,
    required this.scaffold,
    required this.surface,
    required this.surfaceShadow,
    required this.surfaceInnerLayer,
    required this.borderUnfocused,
    required this.borderFocused,
    required this.textBody,
    required this.textHint,
    required this.error,
    required this.success,
    required this.warning,
    required this.iconDisabled,
    required this.overlayDark,
  });

  factory AppColorTokens.fromSeed({required Color seed, required bool isDark}) {
    final HSLColor seedHsl = HSLColor.fromColor(seed);

    return AppColorTokens(
      primary: isDark ? seedHsl.withLightness(_clamp(seedHsl.lightness + 0.08)).toColor() : seed,
      primaryPastel: seedHsl.withLightness(_clamp(seedHsl.lightness + (isDark ? 0.12 : 0.24))).toColor(),
      primaryVeryLight: seedHsl.withLightness(isDark ? 0.24 : 0.92).toColor(),
      linkColor: const Color(0xFF2E6ADE),
      primaryForeground: const Color(0xFFFFFFFF),
      scaffold: isDark ? const Color(0xFF121212) : const Color(0xFFF4F4F4),
      surface: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      surfaceShadow: const Color(0xFF000000).withValues(alpha: isDark ? 0.3 : 0.05),
      surfaceInnerLayer: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
      borderUnfocused: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFDADADA),
      borderFocused: isDark ? const Color(0xFFBBBBBB) : const Color(0xFF444444),
      textBody: isDark ? const Color(0xFFEEEEEE) : const Color(0xFF444444),
      textHint: (isDark ? const Color(0xFFEEEEEE) : const Color(0xFF444444)).withValues(alpha: 0.5),
      error: const Color(0xFFF14336),
      success: isDark ? const Color(0xFF5AB663) : const Color(0xFF3FA65D),
      warning: isDark ? const Color(0xFFF2C230) : const Color(0xFFE0A400),
      iconDisabled: (isDark ? const Color(0xFFEEEEEE) : const Color(0xFF444444)).withValues(alpha: 0.5),
      overlayDark: const Color(0xFF000000).withValues(alpha: isDark ? 0.6 : 0.5),
    );
  }

  static double _clamp(double lightness) => lightness.clamp(0, 1);

  final Color primary;
  final Color primaryPastel;
  final Color primaryVeryLight;
  final Color linkColor;
  final Color primaryForeground;
  final Color scaffold;
  final Color surface;
  final Color surfaceShadow;
  final Color surfaceInnerLayer;
  final Color borderUnfocused;
  final Color borderFocused;
  final Color textBody;
  final Color textHint;
  final Color error;
  final Color success;
  final Color warning;
  final Color iconDisabled;
  final Color overlayDark;

  LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryPastel],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  AppColorTokens copyWith({
    Color? primary,
    Color? primaryPastel,
    Color? primaryVeryLight,
    Color? linkColor,
    Color? primaryForeground,
    Color? scaffold,
    Color? surface,
    Color? surfaceShadow,
    Color? surfaceInnerLayer,
    Color? borderUnfocused,
    Color? borderFocused,
    Color? textBody,
    Color? textHint,
    Color? error,
    Color? success,
    Color? warning,
    Color? iconDisabled,
    Color? overlayDark,
  }) => AppColorTokens(
    primary: primary ?? this.primary,
    primaryPastel: primaryPastel ?? this.primaryPastel,
    primaryVeryLight: primaryVeryLight ?? this.primaryVeryLight,
    linkColor: linkColor ?? this.linkColor,
    primaryForeground: primaryForeground ?? this.primaryForeground,
    scaffold: scaffold ?? this.scaffold,
    surface: surface ?? this.surface,
    surfaceShadow: surfaceShadow ?? this.surfaceShadow,
    surfaceInnerLayer: surfaceInnerLayer ?? this.surfaceInnerLayer,
    borderUnfocused: borderUnfocused ?? this.borderUnfocused,
    borderFocused: borderFocused ?? this.borderFocused,
    textBody: textBody ?? this.textBody,
    textHint: textHint ?? this.textHint,
    error: error ?? this.error,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    iconDisabled: iconDisabled ?? this.iconDisabled,
    overlayDark: overlayDark ?? this.overlayDark,
  );

  @override
  AppColorTokens lerp(AppColorTokens? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColorTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPastel: Color.lerp(primaryPastel, other.primaryPastel, t)!,
      primaryVeryLight: Color.lerp(primaryVeryLight, other.primaryVeryLight, t)!,
      linkColor: Color.lerp(linkColor, other.linkColor, t)!,
      primaryForeground: Color.lerp(primaryForeground, other.primaryForeground, t)!,
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceShadow: Color.lerp(surfaceShadow, other.surfaceShadow, t)!,
      surfaceInnerLayer: Color.lerp(surfaceInnerLayer, other.surfaceInnerLayer, t)!,
      borderUnfocused: Color.lerp(borderUnfocused, other.borderUnfocused, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t)!,
    );
  }
}
