import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/main_navigation/enums/bottom_nav_button_type.dart";

extension TimeCategoryTypeLocalizationX on TimeCategoryType {
  String localizedLabel(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.categoryStudying,
    TimeCategoryType.working => context.l10n.categoryWorking,
    TimeCategoryType.reading => context.l10n.categoryReading,
    TimeCategoryType.hobbies => context.l10n.categoryHobbies,
  };

  String itemNoun(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.itemNounStudying,
    TimeCategoryType.working => context.l10n.itemNounWorking,
    TimeCategoryType.reading => context.l10n.itemNounReading,
    TimeCategoryType.hobbies => context.l10n.itemNounHobbies,
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
