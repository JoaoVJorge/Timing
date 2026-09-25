import "package:flutter/material.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/main_navigation/enums/bottom_nav_button_type.dart";

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

  /// Caption for the time logged on an activity of this category, so a workout
  /// or a hobby is never described as "studied".
  String spentTimeLabel(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.studiedTimeLabel,
    TimeCategoryType.exercises => context.l10n.exercisedTimeLabel,
    TimeCategoryType.reading => context.l10n.readingTimeLabel,
    TimeCategoryType.hobbies => context.l10n.practicedTimeLabel,
  };

  /// The word that follows a period total: reading counts pages, every other
  /// category counts time.
  String periodTotalUnit(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.studiedUnit,
    TimeCategoryType.exercises => context.l10n.exercisedUnit,
    TimeCategoryType.reading => context.l10n.readPagesUnit,
    TimeCategoryType.hobbies => context.l10n.practicedUnit,
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
}

extension LeaderboardPeriodTypeLocalizationX on LeaderboardPeriodType {
  String localizedLabel(BuildContext context) => switch (this) {
    LeaderboardPeriodType.today => context.l10n.periodToday,
    LeaderboardPeriodType.thisWeek => context.l10n.periodThisWeek,
    LeaderboardPeriodType.thisMonth => context.l10n.periodThisMonth,
    LeaderboardPeriodType.total => context.l10n.periodTotal,
  };
}

extension BottomNavButtonTypeLocalizationX on BottomNavButtonType {
  String localizedLabel(BuildContext context) => switch (this) {
    BottomNavButtonType.home => context.l10n.navHome,
    BottomNavButtonType.progress => context.l10n.navProgress,
    BottomNavButtonType.groups => context.l10n.navGroups,
    BottomNavButtonType.config => context.l10n.navSettings,
  };
}
