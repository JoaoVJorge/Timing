import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:help_out/shared/functions/format_duration.dart";

extension TimeCategoryTypeLocalizationX on TimeCategoryType {
  String localizedLabel(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.categoryStudying,
    TimeCategoryType.exercises => context.l10n.categoryExercises,
    TimeCategoryType.reading => context.l10n.categoryReading,
    TimeCategoryType.hobbies => context.l10n.categoryHobbies,
  };

  String itemNoun(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.itemNounStudying,
    TimeCategoryType.exercises => context.l10n.itemNounExercises,
    TimeCategoryType.reading => context.l10n.itemNounReading,
    TimeCategoryType.hobbies => context.l10n.itemNounHobbies,
  };
}

extension GroupThemeTypeLocalizationX on GroupThemeType {
  String localizedLabel(BuildContext context) => switch (this) {
    GroupThemeType.studying => context.l10n.categoryStudying,
    GroupThemeType.dailyGoals => context.l10n.homeTasksSection,
    GroupThemeType.exercises => context.l10n.categoryExercises,
    GroupThemeType.reading => context.l10n.categoryReading,
    GroupThemeType.hobbies => context.l10n.categoryHobbies,
  };

  /// Formats a leaderboard [value] according to how this theme is measured.
  /// Hours-based themes treat [value] as seconds; days/pages as a raw count.
  String formatMetric(BuildContext context, int value) => switch (unit) {
    GroupMetricUnit.hours => formatDurationLong(Duration(seconds: value)),
    GroupMetricUnit.days => context.l10n.metricDaysValue(value),
    GroupMetricUnit.pages => context.l10n.metricPagesValue(value),
  };
}

extension LeaderboardPeriodTypeLocalizationX on LeaderboardPeriodType {
  String localizedLabel(BuildContext context) => switch (this) {
    LeaderboardPeriodType.today => context.l10n.periodToday,
    LeaderboardPeriodType.thisWeek => context.l10n.periodThisWeek,
    LeaderboardPeriodType.thisMonth => context.l10n.periodThisMonth,
  };
}

extension BottomNavButtonTypeLocalizationX on BottomNavButtonType {
  String localizedLabel(BuildContext context) => switch (this) {
    BottomNavButtonType.home => context.l10n.navHome,
    BottomNavButtonType.profile => context.l10n.navProfile,
    BottomNavButtonType.groups => context.l10n.navGroups,
    BottomNavButtonType.config => context.l10n.navSettings,
  };
}
