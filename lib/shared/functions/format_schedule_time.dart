import "package:flutter/material.dart";

/// Formats a minutes-of-day value as a locale-aware clock time (e.g. 14:00).
String formatMinutesOfDay(BuildContext context, int minutes) {
  if (minutes == 24 * 60) {
    return "24:00";
  }

  return TimeOfDay(
    hour: (minutes ~/ 60) % 24,
    minute: minutes % 60,
  ).format(context);
}

/// Formats a schedule slot as "start" or "start - end" when an end is set.
String formatScheduleRange(
  BuildContext context,
  int? startMinutes,
  int? endMinutes,
) {
  if (startMinutes == null && endMinutes == null) {
    return switch (Localizations.localeOf(context).languageCode) {
      "pt" => "Sem horario",
      "es" => "Sin horario",
      "fr" => "Sans horaire",
      "de" => "Ohne Uhrzeit",
      _ => "No time",
    };
  }
  if (startMinutes == null) {
    return switch (Localizations.localeOf(context).languageCode) {
      "pt" => "Ate ${formatMinutesOfDay(context, endMinutes!)}",
      "es" => "Hasta ${formatMinutesOfDay(context, endMinutes!)}",
      "fr" => "Jusqu'a ${formatMinutesOfDay(context, endMinutes!)}",
      "de" => "Bis ${formatMinutesOfDay(context, endMinutes!)}",
      _ => "Until ${formatMinutesOfDay(context, endMinutes!)}",
    };
  }
  if (endMinutes == null) {
    return formatMinutesOfDay(context, startMinutes);
  }
  return "${formatMinutesOfDay(context, startMinutes)} - "
      "${formatMinutesOfDay(context, endMinutes)}";
}
