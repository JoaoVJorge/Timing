import "package:flutter/material.dart";

enum BottomNavButtonType {
  home(icon: Icons.home_outlined, iconSelected: Icons.home, label: "Home"),
  config(icon: Icons.settings_outlined, iconSelected: Icons.settings, label: "Settings");

  const BottomNavButtonType({required this.icon, required this.iconSelected, required this.label});

  final IconData icon;
  final IconData iconSelected;
  final String label;
}
