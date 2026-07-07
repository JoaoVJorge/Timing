/// How a group's leaderboard progress is measured.
enum GroupMetricUnit { hours, days, pages }

/// The five themes a group can be built around. Each mirrors a home category
/// (plus daily goals) and defines how members are ranked against each other.
enum GroupThemeType {
  studying(iconName: "studing", unit: GroupMetricUnit.hours),
  dailyGoals(iconName: "trophy", unit: GroupMetricUnit.days),
  exercises(iconName: "dumbbell", unit: GroupMetricUnit.hours),
  reading(iconName: "open_book", unit: GroupMetricUnit.pages),
  hobbies(iconName: "guitar", unit: GroupMetricUnit.hours);

  const GroupThemeType({required this.iconName, required this.unit});

  final String iconName;
  final GroupMetricUnit unit;

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
