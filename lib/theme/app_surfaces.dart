import "package:flutter/material.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/colors.dart";

/// Decorations for the three surface levels. Content cards keep a hairline
/// border and no shadow; only the primary level carries the accent gradient.
class AppSurfaces {
  const AppSurfaces._();

  static const double contentRadius = 20;
  static const double primaryRadius = 24;
  static const double groupRadius = 18;

  static BoxDecoration content(AppColorTokens tokens) => BoxDecoration(
    color: tokens.surface,
    borderRadius: BorderRadius.circular(contentRadius),
    border: Border.all(color: tokens.borderUnfocused.withValues(alpha: 0.55)),
  );

  static BoxDecoration primary(AppColorTokens tokens) => BoxDecoration(
    gradient: tokens.primaryGradient,
    borderRadius: BorderRadius.circular(primaryRadius),
  );

  /// Container that groups several [AppNavRow]s behind a single border.
  static BoxDecoration rowGroup(AppColorTokens tokens) => BoxDecoration(
    color: tokens.surface,
    borderRadius: BorderRadius.circular(groupRadius),
    border: Border.all(color: tokens.borderUnfocused.withValues(alpha: 0.55)),
  );

  static BoxDecoration of(AppColorTokens tokens, AppSurfaceLevel level) =>
      switch (level) {
        AppSurfaceLevel.primary => primary(tokens),
        AppSurfaceLevel.content => content(tokens),
        AppSurfaceLevel.row => rowGroup(tokens),
      };
}
