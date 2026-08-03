import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

enum AchievementCategory { focus, study, reading, goals, social }

enum RankTier {
  paper,
  wood,
  stone,
  copper,
  bronze,
  iron,
  silver,
  gold,
  platinum,
  amethyst,
  emerald,
  diamond,
  obsidian,
  adamantium,
  mithril,
}

extension RankTierX on RankTier {
  int get minLevel => switch (this) {
    RankTier.paper => 1,
    RankTier.wood => 2,
    RankTier.stone => 3,
    RankTier.copper => 4,
    RankTier.bronze => 5,
    RankTier.iron => 6,
    RankTier.silver => 7,
    RankTier.gold => 8,
    RankTier.platinum => 9,
    RankTier.amethyst => 10,
    RankTier.emerald => 11,
    RankTier.diamond => 12,
    RankTier.obsidian => 13,
    RankTier.adamantium => 14,
    RankTier.mithril => 15,
  };

  Color get color => switch (this) {
    RankTier.paper => const Color(0xFF8A7A5C),
    RankTier.wood => const Color(0xFF8B5A2B),
    RankTier.stone => const Color(0xFF7E858C),
    RankTier.copper => const Color(0xFFB87333),
    RankTier.bronze => const Color(0xFFB07A43),
    RankTier.iron => const Color(0xFF5E6670),
    RankTier.silver => const Color(0xFF9AA7B5),
    RankTier.gold => const Color(0xFFE9A900),
    RankTier.platinum => const Color(0xFF35B7C4),
    RankTier.amethyst => const Color(0xFF8B34B1),
    RankTier.emerald => const Color(0xFF2FA866),
    RankTier.diamond => const Color(0xFF7867E8),
    RankTier.obsidian => const Color(0xFF232129),
    RankTier.adamantium => const Color(0xFF2E6ADE),
    RankTier.mithril => const Color(0xFF66E3EC),
  };

  IconData get icon => switch (this) {
    RankTier.paper => Icons.description_rounded,
    RankTier.wood => Icons.forest_rounded,
    RankTier.stone => Icons.terrain_rounded,
    RankTier.copper => Icons.hardware_rounded,
    RankTier.bronze => Icons.military_tech_rounded,
    RankTier.iron => Icons.construction_rounded,
    RankTier.silver => Icons.military_tech_rounded,
    RankTier.gold => Icons.workspace_premium_rounded,
    RankTier.platinum => Icons.shield_rounded,
    RankTier.amethyst => Icons.diamond_outlined,
    RankTier.emerald => Icons.hexagon_rounded,
    RankTier.diamond => Icons.diamond_rounded,
    RankTier.obsidian => Icons.shield_moon_rounded,
    RankTier.adamantium => Icons.security_rounded,
    RankTier.mithril => Icons.auto_awesome_rounded,
  };

  String label(BuildContext context) => switch (context.languageCode) {
    "pt" => switch (this) {
      RankTier.paper => "Papel",
      RankTier.wood => "Madeira",
      RankTier.stone => "Pedra",
      RankTier.copper => "Cobre",
      RankTier.bronze => "Bronze",
      RankTier.iron => "Ferro",
      RankTier.silver => "Prata",
      RankTier.gold => "Ouro",
      RankTier.platinum => "Platina",
      RankTier.amethyst => "Ametista",
      RankTier.emerald => "Esmeralda",
      RankTier.diamond => "Diamante",
      RankTier.obsidian => "Obsidiana",
      RankTier.adamantium => "Adamantium",
      RankTier.mithril => "Mithril",
    },
    "es" => switch (this) {
      RankTier.paper => "Papel",
      RankTier.wood => "Madera",
      RankTier.stone => "Piedra",
      RankTier.copper => "Cobre",
      RankTier.bronze => "Bronce",
      RankTier.iron => "Hierro",
      RankTier.silver => "Plata",
      RankTier.gold => "Oro",
      RankTier.platinum => "Platino",
      RankTier.amethyst => "Amatista",
      RankTier.emerald => "Esmeralda",
      RankTier.diamond => "Diamante",
      RankTier.obsidian => "Obsidiana",
      RankTier.adamantium => "Adamantium",
      RankTier.mithril => "Mithril",
    },
    _ => switch (this) {
      RankTier.paper => "Paper",
      RankTier.wood => "Wood",
      RankTier.stone => "Stone",
      RankTier.copper => "Copper",
      RankTier.bronze => "Bronze",
      RankTier.iron => "Iron",
      RankTier.silver => "Silver",
      RankTier.gold => "Gold",
      RankTier.platinum => "Platinum",
      RankTier.amethyst => "Amethyst",
      RankTier.emerald => "Emerald",
      RankTier.diamond => "Diamond",
      RankTier.obsidian => "Obsidian",
      RankTier.adamantium => "Adamantium",
      RankTier.mithril => "Mithril",
    },
  };

  String learnerLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Aprendiz ${label(context).toLowerCase()}",
    "es" => "Aprendiz ${label(context).toLowerCase()}",
    _ => "${label(context)} Learner",
  };

  static RankTier forLevel(int level) {
    RankTier tier = RankTier.paper;
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
