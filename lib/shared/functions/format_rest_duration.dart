import "package:flutter/widgets.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";

/// Rest interval label: seconds for exercises ("30s"), localised whole
/// minutes for everything else ("5 min").
String formatRestDuration(
  BuildContext context,
  Duration duration, {
  required bool usesSeconds,
}) => usesSeconds
    ? formatDurationTotalSeconds(duration)
    : context.l10n.restMinutesChip(duration.inMinutes);
