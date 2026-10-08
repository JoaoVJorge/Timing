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

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: page,
  );

  /// Padding of a card or tile that holds a single row of content.
  static const EdgeInsets tile = EdgeInsets.all(14);

  /// Gap each side of a dialog, leaving it as wide as the screen allows.
  static const EdgeInsets dialogInset = EdgeInsets.symmetric(horizontal: 28);

  /// Gap each side of a confirmation dialog, which sits narrower on purpose.
  static const EdgeInsets confirmationDialogInset = EdgeInsets.symmetric(
    horizontal: 34,
  );

  /// Inside a dialog that opens with an illustration above the title.
  static const EdgeInsets illustratedDialog = EdgeInsets.fromLTRB(
    24,
    30,
    24,
    24,
  );

  /// Inside a confirmation dialog: title, message, then a row of buttons.
  static const EdgeInsets confirmationDialog = EdgeInsets.fromLTRB(
    20,
    22,
    20,
    20,
  );

  /// Inside a bottom sheet, below its drag handle.
  static const EdgeInsets bottomSheet = EdgeInsets.fromLTRB(20, 14, 20, 22);
}
