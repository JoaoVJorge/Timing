import "package:intl/intl.dart";
import "package:timing/shared/functions/capitalize_first.dart";

/// "Agosto de 2026" — full month with its locale connector and the year,
/// capitalized for use as a header title.
String formatMonthYearLabel(String locale, DateTime date) =>
    capitalizeFirst(DateFormat.yMMMM(locale).format(date));

/// Two-line month header — the month (with its locale connector, e.g.
/// "Agosto de") on the first line and the year on the second — so the size and
/// weight stay identical for every month.
String formatStackedMonthYearTitle(String locale, DateTime date) {
  final String year = DateFormat.y(locale).format(date);
  final String full = DateFormat.yMMMM(locale).format(date);

  String monthPart = full;
  final int yearIndex = full.lastIndexOf(year);
  if (yearIndex > 0) {
    monthPart = full.substring(0, yearIndex).trim();
  }
  return "${capitalizeFirst(monthPart)}\n$year";
}

/// "Quarta-feira, 20 de agosto" — full weekday and day, capitalized.
String formatFullDateLabel(String locale, DateTime date) =>
    capitalizeFirst(DateFormat.MMMMEEEEd(locale).format(date));

/// "Ago" — abbreviated month name, capitalized.
String formatShortMonthLabel(String locale, int year, int month) =>
    capitalizeFirst(DateFormat.MMM(locale).format(DateTime(year, month)));
