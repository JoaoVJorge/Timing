import "package:flutter/material.dart";
import "package:help_out/theme/colors.dart";

class AppTextStyles {
  const AppTextStyles(this._tokens);

  final AppColorTokens _tokens;

  TextStyle get black32 => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: _tokens.primary,
    height: 1.25,
  );
  TextStyle get black28 => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: _tokens.primary,
    height: 1.25,
  );
  TextStyle get black20 => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: _tokens.primary,
    height: 1.25,
  );

  TextStyle get extraBold24 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: _tokens.textBody,
    height: 1.25,
  );
  TextStyle get extraBold20 => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: _tokens.textBody,
    height: 1.25,
  );

  TextStyle get titleFont => black28;

  /// Page level: one per screen, sits alone at the top.
  TextStyle get pageTitle => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: _tokens.primary,
    height: 1.15,
  );

  /// Section level: introduces a group of cards inside a page.
  TextStyle get sectionTitle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: _tokens.textBody,
    height: 1.2,
  );

  /// Card level: the headline inside a single card or row.
  TextStyle get cardTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: _tokens.textBody,
    height: 1.2,
  );

  /// Numeric readout: the figure a metric card exists to show.
  TextStyle get metricValue => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: _tokens.textBody,
    height: 1.05,
  );

  /// Supporting copy: labels under numbers, hints, meta lines.
  TextStyle get caption => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: _tokens.textHint,
    height: 1.25,
  );

  TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: _tokens.textBody,
  );
  TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _tokens.textBody,
  );
  TextStyle get bodySmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _tokens.textBody,
  );
  TextStyle get bodyTiny => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: _tokens.textBody,
  );

  TextStyle get textButtonMedium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: _tokens.primary,
  );
  TextStyle get textButtonMediumDestructive => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: _tokens.error,
  );

  TextStyle get textPrimaryButton => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: _tokens.primaryForeground,
  );

  TextStyle get hintText => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _tokens.textHint,
  );
  TextStyle get inputText => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _tokens.textBody,
  );
}
