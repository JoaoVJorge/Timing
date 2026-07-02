import "package:flutter/material.dart";
import "package:help_out/theme/colors.dart";

class AppTextStyles {
  const AppTextStyles(this._tokens);

  final AppColorTokens _tokens;

  TextStyle get black32 => TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _tokens.primary, height: 1.25);
  TextStyle get black28 => TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _tokens.primary, height: 1.25);
  TextStyle get black20 => TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _tokens.primary, height: 1.25);

  TextStyle get extraBold24 =>
      TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _tokens.textBody, height: 1.25);
  TextStyle get extraBold20 =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _tokens.textBody, height: 1.25);

  TextStyle get titleFont => black28;

  TextStyle get bodyLarge => TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _tokens.textBody);
  TextStyle get bodyMedium => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _tokens.textBody);
  TextStyle get bodySmall => TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _tokens.textBody);
  TextStyle get bodyTiny => TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _tokens.textBody);

  TextStyle get textButtonMedium => TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _tokens.primary);
  TextStyle get textButtonMediumDestructive =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _tokens.error);

  TextStyle get textPrimaryButton =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _tokens.primaryForeground);

  TextStyle get hintText => TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _tokens.textHint);
  TextStyle get inputText => TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _tokens.textBody);
}
