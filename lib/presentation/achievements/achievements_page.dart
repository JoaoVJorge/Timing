import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/achievements/achievements_controller.dart";
import "package:timing/presentation/achievements/achievements_models.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

part "achievements_page_filters.dart";
part "achievements_page_grid.dart";
part "achievements_page_level_card.dart";
part "achievements_page_ranks_sheet.dart";

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AchievementsController controller = Get.find();

    return AppScaffold(
      padding: EdgeInsets.zero,
      topBar: AppTopBar(
        title: context.l10n.profileAchievementsTitle,
        showBackButton: true,
        onBack: controller.onBack,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _AchievementsLoadingSkeleton();
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _UnlockedSummary(controller: controller),
            ),
            const Gap(8),
            Padding(
              padding: _pageInset,
              child: _LevelCard(controller: controller),
            ),
            const Gap(14),
            _Filters(controller: controller),
            const Gap(12),
            Padding(
              padding: _pageInset,
              child: Obx(
                () => _AchievementsGrid(
                  achievements: controller.filteredAchievements,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Horizontal page gutter. The scaffold body is edge-to-edge for this page so
/// the filter row can scroll from screen edge to screen edge; every other
/// section re-applies this inset.
const EdgeInsets _pageInset = EdgeInsets.symmetric(horizontal: 16);

/// Rebuilds the real page structure with placeholder blocks — same paddings,
/// gaps, card decoration, badge circles and grid math as the loaded state — so
/// the shimmer swaps for content without anything shifting.
class _AchievementsLoadingSkeleton extends StatelessWidget {
  const _AchievementsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const Padding(
          padding: _pageInset,
          child: AppSkeletonBox(width: 180, height: 15, radius: 7),
        ),
        const Gap(12),
        const Padding(padding: _pageInset, child: _LevelCardSkeleton()),
        const Gap(14),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: _pageInset,
          physics: NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              AppSkeletonBox(width: 64, height: 36, radius: 999),
              Gap(8),
              AppSkeletonBox(width: 96, height: 36, radius: 999),
              Gap(8),
              AppSkeletonBox(width: 84, height: 36, radius: 999),
              Gap(8),
              AppSkeletonBox(width: 120, height: 36, radius: 16),
            ],
          ),
        ),
        const Gap(12),
        Padding(
          padding: _pageInset,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 8;
              const int columns = 3;
              final double itemWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (int i = 0; i < 9; i++)
                    SizedBox(
                      width: itemWidth,
                      child: const _AchievementCardSkeleton(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

/// Placeholder twin of [_LevelCard]: identical container padding, radius, inner
/// gaps, divider and the 66 / 38 badge circles.
class _LevelCardSkeleton extends StatelessWidget {
  const _LevelCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(context, radius: 22),
    child: Column(
      children: [
        const Row(
          children: [
            AppSkeletonCircle(size: 66),
            Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonBox(width: 96, height: 14, radius: 6),
                  Gap(2),
                  AppSkeletonBox(width: 150, height: 25, radius: 7),
                  Gap(8),
                  AppSkeletonBox(width: 120, height: 15, radius: 6),
                  Gap(6),
                  AppSkeletonBox(height: 7, radius: 999),
                ],
              ),
            ),
          ],
        ),
        const Gap(12),
        Divider(color: context.colorTokens.divider),
        const Gap(10),
        const Row(
          children: [
            AppSkeletonCircle(size: 38),
            Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonBox(width: 70, height: 11, radius: 5),
                  Gap(2),
                  AppSkeletonBox(width: 150, height: 16, radius: 6),
                  Gap(2),
                  AppSkeletonBox(width: 120, height: 11, radius: 5),
                ],
              ),
            ),
            Gap(8),
            AppSkeletonBox(width: 60, height: 28, radius: 999),
          ],
        ),
      ],
    ),
  );
}

/// Placeholder twin of [_AchievementCard]: same fixed height, radius, padding
/// and the badge / status circles top and bottom.
class _AchievementCardSkeleton extends StatelessWidget {
  const _AchievementCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
    decoration: _cardDecoration(context, radius: 12),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSkeletonCircle(size: 34),
        Gap(6),
        AppSkeletonBox(width: 64, height: 11, radius: 5),
        Gap(4),
        AppSkeletonBox(width: 48, height: 11, radius: 5),
        Gap(4),
        AppSkeletonBox(width: 72, height: 9, radius: 5),
        Spacer(),
        AppSkeletonCircle(size: 18),
      ],
    ),
  );
}

IconData _categoryIcon(AchievementCategory category) => switch (category) {
  AchievementCategory.focus => Icons.bolt_rounded,
  AchievementCategory.study => Icons.school_rounded,
  AchievementCategory.reading => Icons.menu_book_rounded,
  AchievementCategory.goals => Icons.track_changes_rounded,
  AchievementCategory.social => Icons.groups_rounded,
};

Future<void> _showAchievementDetailsDialog(
  BuildContext context,
  AchievementDefinition achievement,
) {
  final Color effectiveColor = achievement.isUnlocked
      ? achievement.color
      : context.colorTokens.iconDisabled;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: context.colorTokens.dialogSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: context.colorTokens.borderUnfocused),
            boxShadow: [
              BoxShadow(
                color: context.colorTokens.black.withValues(alpha: 0.16),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(20),
                    _SmallBadge(
                      icon: achievement.icon,
                      color: effectiveColor,
                      isUnlocked: achievement.isUnlocked,
                      size: 92,
                      iconSize: 46,
                    ),
                    const Gap(16),
                    Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: context.textStyles.extraBold24.copyWith(
                        color: context.colorTokens.dialogText,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodyLarge.copyWith(
                        color: context.colorTokens.dialogTextMuted,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Gap(14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _AchievementInfoPill(
                          label: achievement.category.label(context),
                          icon: _categoryIcon(achievement.category),
                          color: achievement.color,
                          emphasizeIcon: true,
                        ),
                        _AchievementInfoPill(
                          label: achievement.isUnlocked
                              ? context.l10n.unlockedFilterLabel
                              : context.l10n.lockedFilterLabel,
                          icon: achievement.isUnlocked
                              ? Icons.track_changes_rounded
                              : Icons.lock_rounded,
                          color: context.colorTokens.dialogTextMuted,
                        ),
                      ],
                    ),
                    const Gap(20),
                    _AchievementStatusPanel(isUnlocked: achievement.isUnlocked),
                    const Gap(16),
                    _AchievementCloseButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: _AchievementDialogDismissButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AchievementDialogDismissButton extends StatelessWidget {
  const _AchievementDialogDismissButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 44,
    child: IconButton(
      onPressed: onPressed,
      tooltip: MaterialLocalizations.of(context).closeButtonLabel,
      style: IconButton.styleFrom(
        backgroundColor: context.colorTokens.surfaceInnerLayer,
        foregroundColor: context.colorTokens.dialogTextMuted,
      ),
      icon: const Icon(Icons.close_rounded, size: 28),
    ),
  );
}

class _AchievementStatusPanel extends StatelessWidget {
  const _AchievementStatusPanel({required this.isUnlocked});

  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isUnlocked
        ? context.colorTokens.primary
        : context.colorTokens.iconDisabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
              color: context.colorTokens.white,
              size: 26,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUnlocked
                      ? context.l10n.achievementUnlockedDialogTitle
                      : context.l10n.achievementLockedDialogTitle,
                  style: context.textStyles.cardTitle.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(
                  isUnlocked
                      ? context.l10n.achievementUnlockedDialogMessage
                      : context.l10n.achievementLockedDialogMessage,
                  style: context.textStyles.caption.copyWith(
                    color: context.colorTokens.dialogTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCloseButton extends StatelessWidget {
  const _AchievementCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(28);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: context.colorTokens.primaryGradient,
          borderRadius: radius,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: context.colorTokens.primaryForeground,
              shape: RoundedRectangleBorder(borderRadius: radius),
              textStyle: context.textStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            child: Text(
              MaterialLocalizations.of(context).closeButtonLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
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

Future<void> _showRanksSheet(
  BuildContext context,
  AchievementsController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colorTokens.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
  ),
  builder: (_) => FractionallySizedBox(
    heightFactor: 0.82,
    child: _RanksSheet(controller: controller),
  ),
);
