import "package:flutter/widgets.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";

String formatGroupScore(
  BuildContext context,
  int value,
  GroupMetricUnit unit,
) => switch (unit) {
  GroupMetricUnit.hours => formatDurationLong(Duration(seconds: value)),
  GroupMetricUnit.days => context.l10n.metricDaysValue(value),
  GroupMetricUnit.pages => context.l10n.metricPagesValue(value),
};

String formatMetricValue(
  BuildContext context,
  int value,
  GroupMetricUnit unit,
) => switch (unit) {
  GroupMetricUnit.hours => formatDurationTotalMinutes(Duration(seconds: value)),
  GroupMetricUnit.days => context.l10n.metricDaysValue(value),
  GroupMetricUnit.pages => context.l10n.metricPagesValue(value),
};

String progressLabel(
  BuildContext context,
  int current,
  int target,
  GroupMetricUnit unit,
) => switch (unit) {
  GroupMetricUnit.hours =>
    "${_secondsToDisplayMinutes(current)}/${_secondsToDisplayMinutes(target)} min",
  GroupMetricUnit.days => "$current/$target ${context.l10n.daysSuffix}",
  GroupMetricUnit.pages => "$current/$target ${context.l10n.pagesSuffix}",
};

int _secondsToDisplayMinutes(int seconds) => (seconds / 60).ceil();

String groupDescription(BuildContext context, GroupEntity group) =>
    context.l10n.groupDescription(groupMetricDescription(context, group.theme));

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

String leaderboardDescription(
  BuildContext context,
  GroupThemeType theme,
  LeaderboardPeriodType period,
) => context.l10n.groupLeaderboardDescription(
  period.leaderboardDescriptionLabel(context),
  groupMetricDescription(context, theme),
);

String displayMemberName(
  BuildContext context,
  GroupMemberEntity member,
  String currentUserId,
) => member.id == currentUserId ? context.l10n.you : member.name;

String localizedGroupName(BuildContext context, GroupEntity group) =>
    switch (group.id) {
      "study-squad" => context.l10n.mockStudyGroupName,
      "work-crew" => context.l10n.mockWorkoutGroupName,
      _ => group.name,
    };

String formatRankLabel(BuildContext context, int rank) {
  return context.l10n.rankLabel(rank);
}

extension LeaderboardPeriodDescriptionX on LeaderboardPeriodType {
  String leaderboardDescriptionLabel(BuildContext context) => switch (this) {
    LeaderboardPeriodType.today => context.l10n.periodDescriptionToday,
    LeaderboardPeriodType.thisWeek => context.l10n.periodDescriptionThisWeek,
    LeaderboardPeriodType.thisMonth => context.l10n.periodDescriptionThisMonth,
  };
}
