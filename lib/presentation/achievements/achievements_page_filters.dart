part of "achievements_page.dart";

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: context.l10n.allFilterLabel,
            isSelected:
                controller.selectedFilter.value == AchievementFilter.all,
            onTap: () => controller.onSelectFilter(AchievementFilter.all),
          ),
          const Gap(8),
          _FilterChip(
            label: context.l10n.unlockedFilterLabel,
            isSelected:
                controller.selectedFilter.value == AchievementFilter.unlocked,
            onTap: () => controller.onSelectFilter(AchievementFilter.unlocked),
          ),
          const Gap(8),
          _FilterChip(
            label: context.l10n.lockedFilterLabel,
            isSelected:
                controller.selectedFilter.value == AchievementFilter.locked,
            onTap: () => controller.onSelectFilter(AchievementFilter.locked),
          ),
          const Gap(8),
          _CategoryMenu(controller: controller),
        ],
      ),
    ),
  );
}

class _CategoryMenu extends StatelessWidget {
  const _CategoryMenu({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final AchievementCategory? selected = controller.selectedCategory.value;

    return PopupMenuButton<AchievementCategory?>(
      tooltip: context.l10n.selectCategoryTooltip,
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
            label: context.l10n.allCategoriesLabel,
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
        label: selected?.label(context) ?? context.l10n.byCategoryLabel,
        isSelected: selected != null,
        trailing: Icons.keyboard_arrow_down_rounded,
      ),
    );
  });
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
