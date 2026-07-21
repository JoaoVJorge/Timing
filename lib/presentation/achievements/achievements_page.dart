import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/achievements/achievements_controller.dart";
import "package:help_out/presentation/achievements/achievements_models.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AchievementsController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.profileAchievementsTitle,
        showBackButton: true,
        onBack: controller.onBack,
      ),
      body: Obx(() {
        final List<AchievementDefinition> achievements =
            controller.filteredAchievements;

        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _UnlockedSummary(controller: controller),
            const Gap(12),
            _LevelCard(controller: controller),
            const Gap(14),
            _Filters(controller: controller),
            const Gap(12),
            _AchievementsGrid(achievements: achievements),
          ],
        );
      }),
    );
  }
}

class _UnlockedSummary extends StatelessWidget {
  const _UnlockedSummary({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: "${controller.unlockedCount}",
          style: TextStyle(
            color: context.colorTokens.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextSpan(
          text: " /50 unlocked",
          style: TextStyle(color: context.colorTokens.textHint),
        ),
      ],
    ),
    style: context.textStyles.bodyMedium.copyWith(fontSize: 15),
  );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) {
    final AchievementDefinition? nextUnlock = controller.nextUnlock;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context, radius: 22),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorTokens.primaryVeryLight,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: context.colorTokens.primary,
                  size: 36,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current level",
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.textHint,
                      ),
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Gold Learner",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.extraBold20.copyWith(
                              color: context.colorTokens.textBody,
                            ),
                          ),
                        ),
                        const Gap(6),
                        _LevelPill(level: controller.level),
                      ],
                    ),
                    const Gap(8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${controller.levelXp}",
                            style: TextStyle(
                              color: context.colorTokens.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: " / 800 XP",
                            style: TextStyle(
                              color: context.colorTokens.textHint,
                            ),
                          ),
                        ],
                      ),
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: controller.levelProgress,
                        backgroundColor: context.colorTokens.primaryVeryLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colorTokens.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Divider(color: context.colorTokens.divider),
          const Gap(10),
          Row(
            children: [
              _SmallBadge(
                icon: nextUnlock?.icon ?? Icons.done_all_rounded,
                color: nextUnlock?.color ?? context.colorTokens.success,
                isUnlocked: true,
                size: 38,
                iconSize: 19,
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextUnlock == null ? "All unlocked" : "Next unlock",
                      style: context.textStyles.bodyTiny.copyWith(
                        color: context.colorTokens.textHint,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      nextUnlock?.title ?? "Achievement Hunter",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      nextUnlock?.description ?? "You unlocked everything.",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyTiny.copyWith(
                        color: context.colorTokens.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: context.colorTokens.borderUnfocused,
                  ),
                ),
                child: Text(
                  "${800 - controller.levelXp} XP to go",
                  style: context.textStyles.bodyTiny.copyWith(
                    color: context.colorTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      "Level $level",
      style: context.textStyles.bodyTiny.copyWith(
        color: context.colorTokens.primary,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _FilterChip(
          label: "All",
          isSelected: controller.selectedFilter.value == AchievementFilter.all,
          onTap: () => controller.onSelectFilter(AchievementFilter.all),
        ),
        const Gap(8),
        _FilterChip(
          label: "Unlocked",
          isSelected:
              controller.selectedFilter.value == AchievementFilter.unlocked,
          onTap: () => controller.onSelectFilter(AchievementFilter.unlocked),
        ),
        const Gap(8),
        _FilterChip(
          label: "Locked",
          isSelected:
              controller.selectedFilter.value == AchievementFilter.locked,
          onTap: () => controller.onSelectFilter(AchievementFilter.locked),
        ),
        const Gap(8),
        _CategoryMenu(controller: controller),
      ],
    ),
  );
}

class _CategoryMenu extends StatelessWidget {
  const _CategoryMenu({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) {
    final AchievementCategory? selected = controller.selectedCategory.value;

    return PopupMenuButton<AchievementCategory?>(
      tooltip: "Select category",
      initialValue: selected,
      onSelected: controller.onSelectCategory,
      color: context.colorTokens.surface,
      elevation: 8,
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => [
        PopupMenuItem<AchievementCategory?>(
          value: null,
          child: _CategoryOption(
            label: "All categories",
            color: context.colorTokens.primary,
            icon: Icons.apps_rounded,
            isSelected: selected == null,
          ),
        ),
        ...AchievementCategory.values.map(
          (category) => PopupMenuItem<AchievementCategory?>(
            value: category,
            child: _CategoryOption(
              label: category.label(context),
              color: category.color,
              icon: _categoryIcon(category),
              isSelected: selected == category,
            ),
          ),
        ),
      ],
      child: _FilterChip(
        label: selected?.label(context) ?? "By category",
        isSelected: selected != null,
        trailing: Icons.keyboard_arrow_down_rounded,
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.label,
    required this.color,
    required this.icon,
    required this.isSelected,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.16),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
      const Gap(10),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textBody,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      if (isSelected)
        Icon(
          Icons.check_circle_rounded,
          color: context.colorTokens.primary,
          size: 19,
        ),
    ],
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
    this.trailing,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: isSelected
                  ? context.colorTokens.primary
                  : context.colorTokens.textHint,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (trailing != null) ...[
            const Gap(6),
            Icon(
              trailing,
              color: isSelected
                  ? context.colorTokens.primary
                  : context.colorTokens.textHint,
              size: 18,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return BounceTap(onTap: onTap!, pressedScale: 0.96, child: content);
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.achievements});

  final List<AchievementDefinition> achievements;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = 8;
      const int columns = 3;
      final double itemWidth =
          (constraints.maxWidth - (spacing * (columns - 1))) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final AchievementDefinition achievement in achievements)
            SizedBox(
              width: itemWidth,
              child: _AchievementCard(
                key: ValueKey<int>(achievement.id),
                achievement: achievement,
              ),
            ),
        ],
      );
    },
  );
}

class _AchievementCard extends StatefulWidget {
  const _AchievementCard({required this.achievement, super.key});

  final AchievementDefinition achievement;

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AchievementDefinition achievement = widget.achievement;
    final Color effectiveColor = achievement.isUnlocked
        ? achievement.color
        : context.colorTokens.iconDisabled;

    return BounceTap(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: _isExpanded ? 192 : 136,
        padding: const EdgeInsets.fromLTRB(7, 12, 7, 10),
        decoration: _cardDecoration(context, radius: 16),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: _StatusBadge(isUnlocked: achievement.isUnlocked),
            ),
            Column(
              children: [
                _SmallBadge(
                  icon: achievement.icon,
                  color: effectiveColor,
                  isUnlocked: achievement.isUnlocked,
                  size: _isExpanded ? 50 : 46,
                  iconSize: _isExpanded ? 26 : 24,
                ),
                const Gap(10),
                Text(
                  achievement.title,
                  maxLines: _isExpanded ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const Gap(5),
                Expanded(
                  child: Text(
                    achievement.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyTiny.copyWith(
                      color: context.colorTokens.textHint,
                      height: 1.15,
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  const Gap(5),
                  Text(
                    achievement.category.label(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyTiny.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(AchievementCategory category) => switch (category) {
  AchievementCategory.focus => Icons.bolt_rounded,
  AchievementCategory.study => Icons.school_rounded,
  AchievementCategory.reading => Icons.menu_book_rounded,
  AchievementCategory.goals => Icons.track_changes_rounded,
  AchievementCategory.social => Icons.groups_rounded,
};

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.size = 48,
    this.iconSize = 24,
  });

  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: isUnlocked ? 0.18 : 0.12),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Icon(icon, color: color, size: iconSize),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isUnlocked});

  final bool isUnlocked;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isUnlocked
          ? context.colorTokens.primary
          : context.colorTokens.borderUnfocused,
    ),
    child: Icon(
      isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
      color: context.colorTokens.white,
      size: 12,
    ),
  );
}

BoxDecoration _cardDecoration(BuildContext context, {required double radius}) =>
    BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
