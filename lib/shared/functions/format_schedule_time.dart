import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

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

/// Completes a partially typed time into a full "HH:MM". Typing just an hour
/// ("10") settles into "10:00"; a single minute digit ("10:3") fills to "10:30".
/// Returns null when there is nothing to complete (empty input).
String? completePartialTime(String raw) {
  final String text = raw.trim();
  if (text.isEmpty) {
    return null;
  }
  final List<String> parts = text.split(":");
  if (parts[0].isEmpty) {
    return null;
  }
  int hour = (int.tryParse(parts[0]) ?? 0).clamp(0, 24);
  final String minuteDigits = parts.length > 1 ? parts[1] : "";
  int minute = minuteDigits.isEmpty
      ? 0
      : (int.tryParse(minuteDigits.padRight(2, "0")) ?? 0);
  if (hour == 24) {
    minute = 0;
  }
  minute = minute.clamp(0, 59);
  return "${hour.toString().padLeft(2, "0")}:"
      "${minute.toString().padLeft(2, "0")}";
}

/// Formats a [dateTime] as a local "HH:MM" clock time (e.g. a chat timestamp).
String formatClockTime(DateTime dateTime) {
  final DateTime local = dateTime.toLocal();
  return "${local.hour.toString().padLeft(2, "0")}:"
      "${local.minute.toString().padLeft(2, "0")}";
}

/// Normalizes a raw digit string typed into a time field, clamping the hour to
/// 0-24 and the minutes to 0-59 (24:XX settles to 24:00). Used by the input
/// mask before the ":" separator is inserted.
String normalizeTimeDigits(String digits) {
  if (digits.length < 2) {
    return digits;
  }

  final int hour = int.parse(digits.substring(0, 2)).clamp(0, 24).toInt();
  final String hourDigits = hour.toString().padLeft(2, "0");
  if (digits.length == 2) {
    return hourDigits;
  }

  String minuteDigits = digits.substring(2);
  if (hour == 24) {
    minuteDigits = List.filled(minuteDigits.length, "0").join();
    return "$hourDigits$minuteDigits";
  }

  if (minuteDigits.isNotEmpty && int.parse(minuteDigits[0]) > 5) {
    minuteDigits =
        "5${minuteDigits.length > 1 ? minuteDigits.substring(1) : ""}";
  }
  if (minuteDigits.length == 2) {
    final int minute = int.parse(minuteDigits).clamp(0, 59).toInt();
    minuteDigits = minute.toString().padLeft(2, "0");
  }

  return "$hourDigits$minuteDigits";
}

/// Formats a schedule slot as "start" or "start - end" when an end is set.
String formatScheduleRange(
  BuildContext context,
  int? startMinutes,
  int? endMinutes,
) {
  if (startMinutes == null && endMinutes == null) {
    return context.l10n.noTimeLabel;
  }
  if (startMinutes == null) {
    return context.l10n.untilTimeLabel(
      formatMinutesOfDay(context, endMinutes!),
    );
  }
  if (endMinutes == null) {
    return formatMinutesOfDay(context, startMinutes);
  }
  return "${formatMinutesOfDay(context, startMinutes)} - "
      "${formatMinutesOfDay(context, endMinutes)}";
}
