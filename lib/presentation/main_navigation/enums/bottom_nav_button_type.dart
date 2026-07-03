enum BottomNavButtonType {
  home(iconName: "home", label: "Home"),
  profile(iconName: "trophy", label: "Profile"),
  groups(iconName: "group", label: "Groups"),
  config(iconName: "address_book", label: "Settings");

  const BottomNavButtonType({required this.iconName, required this.label});

  final String iconName;
  final String label;
}
