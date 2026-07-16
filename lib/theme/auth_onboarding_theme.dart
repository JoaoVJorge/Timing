import "package:flutter/material.dart";

class AuthOnboardingColors {
  const AuthOnboardingColors._();

  static const Color background = Color(0xFFFFFAEE);
  static const Color backgroundWarm = Color(0xFFFFF4D8);
  static const Color navy = Color(0xFF071A44);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textSoft = Color(0xFF8A8F9B);
  static const Color yellow = Color(0xFFFFBE24);
  static const Color yellowDark = Color(0xFFF2A900);
  static const Color yellowLight = Color(0xFFFFE7A4);

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC329), Color(0xFFFFB919)],
  );
}

class AuthOnboardingTextStyles {
  const AuthOnboardingTextStyles._();

  static const TextStyle brand = TextStyle(
    color: AuthOnboardingColors.navy,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const TextStyle title = TextStyle(
    color: AuthOnboardingColors.navy,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    height: 1.06,
    letterSpacing: 0,
  );

  static const TextStyle subtitle = TextStyle(
    color: AuthOnboardingColors.textMuted,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0,
  );

  static const TextStyle button = TextStyle(
    color: AuthOnboardingColors.navy,
    fontSize: 20,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const TextStyle link = TextStyle(
    color: AuthOnboardingColors.navy,
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const TextStyle fieldLabel = TextStyle(
    color: AuthOnboardingColors.textMuted,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle fieldValue = TextStyle(
    color: AuthOnboardingColors.navy,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const TextStyle fieldHint = TextStyle(
    color: AuthOnboardingColors.textSoft,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle sparkle = TextStyle(
    color: AuthOnboardingColors.yellowDark,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );
}

class AuthOnboardingDecorations {
  const AuthOnboardingDecorations._();

  static BoxDecoration get card => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AuthOnboardingColors.navy.withValues(alpha: 0.09),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
