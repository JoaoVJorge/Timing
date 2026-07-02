import "package:flutter/material.dart";

enum TimeCategoryType {
  studying(label: "Studying", icon: Icons.school_outlined),
  working(label: "Working", icon: Icons.work_outline),
  reading(label: "Reading", icon: Icons.menu_book_outlined),
  hobbies(label: "Hobbies", icon: Icons.palette_outlined);

  const TimeCategoryType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
