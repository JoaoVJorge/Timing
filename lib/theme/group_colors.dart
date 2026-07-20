import "package:flutter/material.dart";

class GroupAvatarColors {
  const GroupAvatarColors._();

  static const List<int> values = [
    0xFFE0507A,
    0xFF2E6ADE,
    0xFF3FA65D,
    0xFF8325FF,
    0xFF1FA2A6,
    0xFFFF7A30,
  ];

  static int byIndex(int index) => values[index.abs() % values.length];
}

class LeaderboardMedalColors {
  const LeaderboardMedalColors._();

  static const Color gold = Color(0xFFFFC107);
  static const Color silver = Color(0xFFB0BEC5);
  static const Color bronze = Color(0xFFD08A55);

  static const List<Color> values = [gold, silver, bronze];

  static Color byRank(int rank) => values[(rank - 1).clamp(0, 2)];
}
