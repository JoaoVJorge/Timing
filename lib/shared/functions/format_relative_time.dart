import "package:flutter/widgets.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

/// Localised "time ago" label for a past [timestamp] (e.g. "2 h ago").
String formatRelativeTime(BuildContext context, DateTime timestamp) {
  final Duration difference = DateTime.now().difference(timestamp);
  if (difference.inMinutes < 1) {
    return context.l10n.lastActivityJustNow;
  }
  if (difference.inHours < 1) {
    return context.l10n.lastActivityMinutesAgo(difference.inMinutes);
  }
  if (difference.inDays < 1) {
    return context.l10n.lastActivityHoursAgo(difference.inHours);
  }
  return context.l10n.lastActivityDaysAgo(difference.inDays);
}
