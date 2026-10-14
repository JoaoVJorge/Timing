import "package:timing/core/domain/enums/time_category_type.dart";

/// How a group's leaderboard progress is measured.
enum GroupMetricUnit { hours, days, pages }

/// The five themes a group can be built around. Each mirrors a home category
/// (plus daily goals) and defines how members are ranked against each other
/// and which of their activities they can link to the group.
enum GroupThemeType {
  studying(iconName: "graduate", unit: GroupMetricUnit.hours),
  dailyGoals(iconName: "trophy", unit: GroupMetricUnit.days),
  exercises(iconName: "bicycle", unit: GroupMetricUnit.hours),
  reading(iconName: "open-book", unit: GroupMetricUnit.pages),
  hobbies(iconName: "guitar", unit: GroupMetricUnit.hours);

  const GroupThemeType({required this.iconName, required this.unit});

  final String iconName;
  final GroupMetricUnit unit;

  /// The home category whose activities members link to a group of this
  /// theme. Null for [dailyGoals], which takes a goal instead.
  TimeCategoryType? get category => switch (this) {
    GroupThemeType.studying => TimeCategoryType.studying,
    GroupThemeType.exercises => TimeCategoryType.exercises,
    GroupThemeType.reading => TimeCategoryType.reading,
    GroupThemeType.hobbies => TimeCategoryType.hobbies,
    GroupThemeType.dailyGoals => null,
  };

  /// Falls back to [studying] for unknown/legacy values so persisted groups
  /// saved before themes existed keep working.
  static GroupThemeType byName(String? name) {
    for (final GroupThemeType value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return GroupThemeType.studying;
  }
}
