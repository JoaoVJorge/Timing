import "package:flutter/material.dart";
import "package:help_out/l10n/app_localizations.dart";
import "package:help_out/theme/colors.dart";
import "package:help_out/theme/text_styles.dart";

extension AppColorTokensX on BuildContext {
  AppColorTokens get colorTokens => Theme.of(this).extension<AppColorTokens>()!;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension AppTextStylesX on BuildContext {
  AppTextStyles get textStyles => AppTextStyles(colorTokens);
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
