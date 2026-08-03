enum BottomNavButtonType {
  home(iconName: "home"),
  progress(iconName: "trophy"),
  groups(iconName: "group"),
  config(iconName: "settings");

  const BottomNavButtonType({required this.iconName});

  final String iconName;
}
