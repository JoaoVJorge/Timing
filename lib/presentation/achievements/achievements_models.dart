import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

enum AchievementCategory { focus, study, reading, goals, social }

enum RankTier { bronze, silver, gold, platinum, diamond }

extension RankTierX on RankTier {
  int get minLevel => switch (this) {
    RankTier.bronze => 1,
    RankTier.silver => 2,
    RankTier.gold => 3,
    RankTier.platinum => 4,
    RankTier.diamond => 5,
  };

  Color get color => switch (this) {
    RankTier.bronze => const Color(0xFFB07A43),
    RankTier.silver => const Color(0xFF9AA7B5),
    RankTier.gold => const Color(0xFFE9A900),
    RankTier.platinum => const Color(0xFF35B7C4),
    RankTier.diamond => const Color(0xFF7867E8),
  };

  IconData get icon => switch (this) {
    RankTier.bronze => Icons.military_tech_rounded,
    RankTier.silver => Icons.military_tech_rounded,
    RankTier.gold => Icons.workspace_premium_rounded,
    RankTier.platinum => Icons.shield_rounded,
    RankTier.diamond => Icons.diamond_rounded,
  };

  String label(BuildContext context) => switch (context.languageCode) {
    "pt" => switch (this) {
      RankTier.bronze => "Bronze",
      RankTier.silver => "Prata",
      RankTier.gold => "Ouro",
      RankTier.platinum => "Platina",
      RankTier.diamond => "Diamante",
    },
    "es" => switch (this) {
      RankTier.bronze => "Bronce",
      RankTier.silver => "Plata",
      RankTier.gold => "Oro",
      RankTier.platinum => "Platino",
      RankTier.diamond => "Diamante",
    },
    _ => switch (this) {
      RankTier.bronze => "Bronze",
      RankTier.silver => "Silver",
      RankTier.gold => "Gold",
      RankTier.platinum => "Platinum",
      RankTier.diamond => "Diamond",
    },
  };

  String learnerLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Aprendiz ${label(context).toLowerCase()}",
    "es" => "Aprendiz ${label(context).toLowerCase()}",
    _ => "${label(context)} Learner",
  };

  static RankTier forLevel(int level) {
    RankTier tier = RankTier.bronze;
    for (final RankTier candidate in RankTier.values) {
      if (level >= candidate.minLevel) {
        tier = candidate;
      }
    }
    return tier;
  }
}

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
