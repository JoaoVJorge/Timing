import "package:flutter/widgets.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";

String formatGroupScore(
  BuildContext context,
  int value,
  GroupMetricUnit unit,
) => switch (unit) {
  GroupMetricUnit.hours => formatDurationLong(Duration(seconds: value)),
  GroupMetricUnit.days => context.l10n.metricDaysValue(value),
  GroupMetricUnit.pages => context.l10n.metricPagesValue(value),
};

String groupMetricDescription(BuildContext context, GroupThemeType theme) =>
    switch (theme) {
      GroupThemeType.studying => context.l10n.groupMetricStudying,
      GroupThemeType.dailyGoals => context.l10n.groupMetricDailyGoals,
      GroupThemeType.exercises => context.l10n.groupMetricExercises,
      GroupThemeType.reading => context.l10n.groupMetricReading,
      GroupThemeType.hobbies => context.l10n.groupMetricHobbies,
    };

String leaderboardDescription(
  BuildContext context,
  GroupThemeType theme,
  LeaderboardPeriodType period,
) => context.l10n.groupLeaderboardDescription(
  period.leaderboardDescriptionLabel(context),
  groupMetricDescription(context, theme),
);

String localizedGroupName(BuildContext context, GroupEntity group) =>
    switch (group.id) {
      "study-squad" => context.l10n.mockStudyGroupName,
      "work-crew" => context.l10n.mockWorkoutGroupName,
      _ => group.name,
    };

String displayMemberName(
  BuildContext context,
  GroupMemberEntity member,
  String currentUserId,
) => member.id == currentUserId ? context.l10n.you : member.name;

String formatRankLabel(BuildContext context, int rank) {
  final String languageCode = Localizations.localeOf(context).languageCode;
  if (languageCode == "en") {
    final int lastTwoDigits = rank % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
      return "${rank}th";
    }
    return switch (rank % 10) {
      1 => "${rank}st",
      2 => "${rank}nd",
      3 => "${rank}rd",
      _ => "${rank}th",
    };
  }
  return "$rankº";
}

extension LeaderboardPeriodDescriptionX on LeaderboardPeriodType {
  String leaderboardDescriptionLabel(BuildContext context) => switch (this) {
    LeaderboardPeriodType.today => context.l10n.periodDescriptionToday,
    LeaderboardPeriodType.thisWeek => context.l10n.periodDescriptionThisWeek,
    LeaderboardPeriodType.thisMonth => context.l10n.periodDescriptionThisMonth,
  };
}
