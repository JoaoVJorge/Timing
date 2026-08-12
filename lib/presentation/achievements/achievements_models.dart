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

  String label(BuildContext context) => switch (this) {
    RankTier.paper => context.l10n.rankTierPaper,
    RankTier.wood => context.l10n.rankTierWood,
    RankTier.stone => context.l10n.rankTierStone,
    RankTier.copper => context.l10n.rankTierCopper,
    RankTier.bronze => context.l10n.rankTierBronze,
    RankTier.iron => context.l10n.rankTierIron,
    RankTier.silver => context.l10n.rankTierSilver,
    RankTier.gold => context.l10n.rankTierGold,
    RankTier.platinum => context.l10n.rankTierPlatinum,
    RankTier.amethyst => context.l10n.rankTierAmethyst,
    RankTier.emerald => context.l10n.rankTierEmerald,
    RankTier.diamond => context.l10n.rankTierDiamond,
    RankTier.obsidian => context.l10n.rankTierObsidian,
    RankTier.adamantium => context.l10n.rankTierAdamantium,
    RankTier.mithril => context.l10n.rankTierMithril,
  };

  String learnerLabel(BuildContext context) =>
      context.l10n.rankTierLearner(label(context).toLowerCase());

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
