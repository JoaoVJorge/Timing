part of "achievements_page.dart";

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _pageInset,
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

/// UI-only wrapper so "All categories" carries a real (non-null) value.
/// A [PopupMenuButton] routes a `null` selection to `onCanceled`, never
/// `onSelected`, which is why picking "All categories" used to do nothing.
enum _CategoryFilter {
  all(null),
  focus(AchievementCategory.focus),
  study(AchievementCategory.study),
  reading(AchievementCategory.reading),
  goals(AchievementCategory.goals),
  social(AchievementCategory.social);

  const _CategoryFilter(this.category);

  final AchievementCategory? category;

  static _CategoryFilter of(AchievementCategory? category) =>
      values.firstWhere((filter) => filter.category == category);
}

/// Mirrors the group leaderboard's period filter: a gradient trigger and a
/// menu that drops straight under it with icon / label / check rows.
class _CategoryMenu extends StatelessWidget {
  const _CategoryMenu({required this.controller});

  final AchievementsController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final AchievementCategory? selected = controller.selectedCategory.value;
    final BorderRadius buttonRadius = BorderRadius.circular(16);

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(highlightColor: context.colorTokens.primaryVeryLight),
      child: PopupMenuButton<_CategoryFilter>(
        key: const ValueKey("achievements-category-filter"),
        tooltip: context.l10n.selectCategoryTooltip,
        initialValue: _CategoryFilter.of(selected),
        onSelected: (filter) => controller.onSelectCategory(filter.category),
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        color: context.colorTokens.surface,
        surfaceTintColor: context.colorTokens.transparent,
        elevation: 8,
        menuPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        borderRadius: buttonRadius,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        itemBuilder: (context) => [
          for (final _CategoryFilter filter in _CategoryFilter.values)
            PopupMenuItem<_CategoryFilter>(
              value: filter,
              child: _CategoryMenuRow(
                filter: filter,
                isSelected: filter.category == selected,
              ),
            ),
        ],
        child: Container(
          constraints: const BoxConstraints(minWidth: 120, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: context.colorTokens.primaryGradient,
            borderRadius: buttonRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  selected?.label(context) ?? context.l10n.allCategoriesLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.primaryForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Gap(8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 21,
                color: context.colorTokens.primaryForeground,
              ),
            ],
          ),
        ),
      ),
    );
  });
}

class _CategoryMenuRow extends StatelessWidget {
  const _CategoryMenuRow({required this.filter, required this.isSelected});

  final _CategoryFilter filter;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final AchievementCategory? category = filter.category;
    final Color color = category?.color ?? context.colorTokens.primary;
    final IconData icon = category == null
        ? Icons.apps_rounded
        : _categoryIcon(category);

    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const Gap(12),
        Expanded(
          child: Text(
            category?.label(context) ?? context.l10n.allCategoriesLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textBody,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        if (isSelected) ...[
          const Gap(16),
          Icon(
            Icons.check_rounded,
            size: 22,
            color: context.colorTokens.primary,
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

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
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return BounceTap(onTap: onTap!, pressedScale: 0.96, child: content);
  }
}
