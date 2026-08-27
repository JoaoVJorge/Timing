import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/achievements/achievements_controller.dart";
import "package:timing/presentation/achievements/achievements_models.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

part "achievements_page_level_card.dart";
part "achievements_page_filters.dart";
part "achievements_page_grid.dart";
part "achievements_page_ranks_sheet.dart";

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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _UnlockedSummary(controller: controller),
          const Gap(12),
          _LevelCard(controller: controller),
          const Gap(14),
          _Filters(controller: controller),
          const Gap(12),
          Obx(
            () => _AchievementsGrid(
              achievements: controller.filteredAchievements,
            ),
          ),
        ],
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
          decoration: _cardDecoration(context, radius: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SmallBadge(
                  icon: achievement.icon,
                  color: effectiveColor,
                  isUnlocked: achievement.isUnlocked,
                  size: 64,
                  iconSize: 32,
                ),
                const Gap(12),
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: context.textStyles.extraBold20.copyWith(
                    color: context.colorTokens.textBody,
                    height: 1.12,
                  ),
                ),
                const Gap(8),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textHint,
                    height: 1.24,
                  ),
                ),
                const Gap(14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _AchievementInfoPill(
                      label: achievement.category.label(context),
                    ),
                    _AchievementInfoPill(
                      label: achievement.isUnlocked
                          ? context.l10n.unlockedFilterLabel
                          : context.l10n.lockedFilterLabel,
                    ),
                    _AchievementInfoPill(label: "#${achievement.id}"),
                  ],
                ),
                const Gap(20),
                _StatusBadge(
                  isUnlocked: achievement.isUnlocked,
                  size: 34,
                  iconSize: 20,
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).closeButtonLabel,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
