import "package:flutter/widgets.dart";

/// Single spacing grid used across the app so unrelated screens stop inventing
/// their own rhythm.
class AppSpacing {
  const AppSpacing._();

  /// Between a title and the text that explains it.
  static const double titleToDescription = 8;

  /// Between cards that belong to the same block.
  static const double betweenRelated = 12;

  /// Horizontal page margin.
  static const double page = 16;

  /// Between two different sections of a page.
  static const double betweenSections = 24;

  /// Smallest height a tappable element may have.
  static const double minTapTarget = 48;

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: page);
}

/// The three visual levels a surface can take. Keeping them explicit avoids the
/// "everything is a white rounded card" flattening.
enum AppSurfaceLevel {
  /// Priority action. Filled with the accent gradient.
  primary,

  /// Regular content: agenda, progress, ranking.
  content,

  /// Secondary navigation rows grouped inside a single container.
  row,
}
