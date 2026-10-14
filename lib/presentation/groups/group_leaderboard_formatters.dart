import "package:flutter/widgets.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";

String formatGroupScore(
  BuildContext context,
  int value,
  GroupMetricUnit unit,
) => switch (unit) {
  GroupMetricUnit.hours => _formatFocusTime(value, formatDurationLong),
  GroupMetricUnit.days => context.l10n.metricDaysValue(value),
  GroupMetricUnit.pages => context.l10n.metricPagesValue(value),
};

/// The minute formats floor, so a short session would read "0 min" and look
/// like the group ignored it. Below a minute the exact seconds are shown.
String _formatFocusTime(int seconds, String Function(Duration) formatMinutes) =>
    seconds > 0 && seconds < 60
    ? formatDurationTotalSeconds(Duration(seconds: seconds))
    : formatMinutes(Duration(seconds: seconds));

String friendsCardSubtitle(BuildContext context, int groupCount) =>
    context.l10n.groupsFriendsSubtitleWithCount(groupCount);

String groupMetricDescription(BuildContext context, GroupThemeType theme) =>
    switch (theme) {
      GroupThemeType.studying => context.l10n.groupMetricStudying,
      GroupThemeType.dailyGoals => context.l10n.groupMetricDailyGoals,
      GroupThemeType.exercises => context.l10n.groupMetricExercises,
      GroupThemeType.reading => context.l10n.groupMetricReading,
      GroupThemeType.hobbies => context.l10n.groupMetricHobbies,
    };

/// Which of their own activities a member may link to a group of [theme].
String groupLinksHint(BuildContext context, GroupThemeType theme) =>
    switch (theme) {
      GroupThemeType.studying => context.l10n.groupLinksHintStudying,
      GroupThemeType.dailyGoals => context.l10n.groupLinksHintDailyGoals,
      GroupThemeType.exercises => context.l10n.groupLinksHintExercises,
      GroupThemeType.reading => context.l10n.groupLinksHintReading,
      GroupThemeType.hobbies => context.l10n.groupLinksHintHobbies,
    };

String localizedGroupName(BuildContext context, GroupEntity group) =>
    switch (group.id) {
      "study-squad" => context.l10n.mockStudyGroupName,
      "work-crew" => context.l10n.mockWorkoutGroupName,
      _ => group.name,
    };

String formatRankLabel(BuildContext context, int rank) {
  return context.l10n.rankLabel(rank);
}
