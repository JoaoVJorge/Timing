import "package:flutter/material.dart";

/// Formats a minutes-of-day value as a locale-aware clock time (e.g. 14:00).
String formatMinutesOfDay(BuildContext context, int minutes) => TimeOfDay(
  hour: (minutes ~/ 60) % 24,
  minute: minutes % 60,
).format(context);

/// Formats a schedule slot as "start" or "start - end" when an end is set.
String formatScheduleRange(
  BuildContext context,
  int startMinutes,
  int? endMinutes,
) => endMinutes == null
    ? formatMinutesOfDay(context, startMinutes)
    : "${formatMinutesOfDay(context, startMinutes)} - "
          "${formatMinutesOfDay(context, endMinutes)}";
