enum TimeCategoryType {
  studying(iconName: "studing"),
  working(iconName: "building"),
  reading(iconName: "open_book"),
  hobbies(iconName: "guitar");

  const TimeCategoryType({required this.iconName});

  final String iconName;
}
