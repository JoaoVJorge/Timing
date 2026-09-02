import "package:flutter/material.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/theme/colors.dart";
import "package:timing/theme/text_styles.dart";

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

/// Keyed by the theme's [AppColorTokens] instance, which is stable while the
/// seed and brightness stay put (see `AppThemes.build`), so `context.textStyles`
/// stops allocating a fresh holder on every call in hot build paths.
final Expando<AppTextStyles> _textStylesByTokens = Expando<AppTextStyles>();

extension AppTextStylesX on BuildContext {
  AppTextStyles get textStyles {
    final AppColorTokens tokens = colorTokens;
    return _textStylesByTokens[tokens] ??= AppTextStyles(tokens);
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get createTaskHeroTitle =>
      l10n.createTaskTitle.replaceFirst(" ", "\n");

  String get languageCode => Localizations.localeOf(this).languageCode;

  String get daysSuffix => l10n.daysSuffix;

  String get createTaskSubtitle => l10n.createTaskSubtitle;
}
