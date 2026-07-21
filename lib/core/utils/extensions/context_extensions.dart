import "package:flutter/material.dart";
import "package:help_out/l10n/app_localizations.dart";
import "package:help_out/theme/colors.dart";
import "package:help_out/theme/text_styles.dart";

extension AppColorTokensX on BuildContext {
  AppColorTokens get colorTokens => Theme.of(this).extension<AppColorTokens>()!;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get creationPageBackground {
    if (isDarkMode) return colorTokens.scaffold;

    return Color.lerp(colorTokens.primaryVeryLight, colorTokens.white, 0.96) ??
        colorTokens.scaffold;
  }

  BoxDecoration creationCardDecoration(Color accent) => BoxDecoration(
    color: colorTokens.surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: accent.withValues(alpha: 0.16)),
  );
}

extension AppTextStylesX on BuildContext {
  AppTextStyles get textStyles => AppTextStyles(colorTokens);
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get createTaskHeroTitle =>
      l10n.createTaskTitle.replaceFirst(" ", "\n");

  String get languageCode => Localizations.localeOf(this).languageCode;

  String get daysSuffix => switch (languageCode) {
    "pt" => "dias",
    "es" => "días",
    _ => "days",
  };

  String get createTaskSubtitle => switch (languageCode) {
    "pt" => "Configure uma meta diária para acompanhar seu progresso",
    "es" => "Configura una meta diaria para seguir tu progreso",
    _ => "Set a daily goal and keep track of your progress",
  };
}
