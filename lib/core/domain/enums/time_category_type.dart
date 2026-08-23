enum TimeCategoryType {
  studying(iconName: "graduate"),
  exercises(iconName: "bicycle"),
  reading(iconName: "open-book"),
  hobbies(iconName: "guitar");

  const TimeCategoryType({required this.iconName});

  final String iconName;

  static TimeCategoryType? tryByName(String name) {
    for (final TimeCategoryType value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}
