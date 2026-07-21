import "package:flutter/material.dart";

enum AchievementCategory { focus, study, reading, goals, social }

enum AchievementFilter { all, unlocked, locked }

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.category,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final int id;
  final AchievementCategory category;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool isUnlocked;
}
