import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/app/app_ui_constants.dart";
import "package:timing/core/domain/entities/profile_stats_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/progress/progress_category_style.dart";
import "package:timing/presentation/progress/progress_controller.dart";
import "package:timing/presentation/progress/widgets/progress_achievements_section.dart";
import "package:timing/presentation/progress/widgets/progress_evolution_chart.dart";
import "package:timing/presentation/progress/widgets/progress_hero_card.dart";
import "package:timing/presentation/progress/widgets/progress_period_tabs.dart";
import "package:timing/presentation/progress/widgets/progress_stat_row.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/app_icon_badge.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_section_header.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/app_spacing.dart";
import "package:timing/theme/app_surfaces.dart";

/// Answers a single question: "what have I already done?". Planning lives on
/// Home and social lives in Groups, so nothing else competes for attention.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressController controller = Get.find();

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppUiConstants.pagePadding,
          16,
          AppUiConstants.pagePadding,
          AppSpacing.betweenSections,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _ProgressLoadingSkeleton();
          }

          final ProfileStatsEntity stats = controller.stats.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProgressHeader(),
              const Gap(AppSpacing.betweenSections - 4),
              ProgressPeriodTabs(
                selectedPeriod: controller.selectedPeriod.value,
                onSelectPeriod: controller.onSelectPeriod,
              ),
              const Gap(AppSpacing.betweenRelated),
              ProgressHeroCard(
                focusSeconds: controller.selectedPeriodFocusSeconds,
                differenceToPreviousPeriod:
                    controller.focusDifferenceToPreviousPeriod,
              ),
              const Gap(AppSpacing.betweenRelated),
              ProgressStatRow(
                stats: [
                  (
                    icon: Icons.schedule_rounded,
                    value: formatDurationLong(
                      Duration(seconds: controller.selectedPeriodFocusSeconds),
                    ),
                    label: context.l10n.profileSummaryFocusLabel,
                    accent: TimeCategoryType.studying.accentColor,
                  ),
                  (
                    icon: Icons.flag_rounded,
                    value:
                        controller.longestGoal?.name ??
                        context.l10n.profileTopSubjectEmptyTitle,
                    label: context.l10n.progressStatLongestGoal,
                    accent: ProgressAccentColors.pink,
                  ),
                  (
                    icon: Icons.auto_stories_rounded,
                    value:
                        controller.mainReadingSubject?.name ??
                        context.l10n.profileTopSubjectEmptyTitle,
                    label: context.l10n.progressStatMainReading,
                    accent: TimeCategoryType.reading.accentColor,
                  ),
                  (
                    icon: Icons.assignment_rounded,
                    value: "${controller.selectedPeriodSessions}",
                    label: context.l10n.homeSummarySessions,
                    accent: ProgressAccentColors.blue,
                  ),
                ],
              ),
              const Gap(AppSpacing.betweenSections),
              AppSectionHeader(title: context.l10n.profileEvolutionTitle),
              const Gap(AppSpacing.betweenRelated),
              ProgressEvolutionChart(values: controller.evolutionFocusSeconds),
              const Gap(AppSpacing.betweenSections),
              AppSectionHeader(title: context.l10n.progressDistributionTitle),
              const Gap(AppSpacing.betweenRelated),
              _DistributionCard(controller: controller),
              const Gap(AppSpacing.betweenSections),
              ProgressAchievementsSection(
                hasGoalStarted: controller.hasGoalStarted,
                hasValidFirstFocus: controller.hasValidFirstFocus,
                activeDays: controller.activeDays,
                sessions: controller.totalSessions,
                readingPages: stats.readingTotalPages,
                focusSeconds: stats.totalFocusSeconds,
                onTap: controller.onTapAchievements,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProgressLoadingSkeleton extends StatelessWidget {
  const _ProgressLoadingSkeleton();

  @override
  Widget build(BuildContext context) => const AppSkeleton(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonBox(width: 150, height: 30, radius: 9),
        Gap(AppSpacing.titleToDescription),
        AppSkeletonBox(height: 14, radius: 7),
        Gap(4),
        AppSkeletonBox(width: 220, height: 14, radius: 7),
        Gap(AppSpacing.betweenSections - 4),
        AppSkeletonBox(width: double.infinity, height: 56, radius: 16),
        Gap(AppSpacing.betweenRelated),
        AppSkeletonBox(
          width: double.infinity,
          height: 140,
          radius: AppSurfaces.primaryRadius,
        ),
        Gap(AppSpacing.betweenRelated),
        _ProgressStatsSkeleton(),
        Gap(AppSpacing.betweenSections),
        AppSkeletonBox(width: 128, height: 20, radius: 7),
        Gap(AppSpacing.betweenRelated),
        AppSkeletonBox(
          width: double.infinity,
          height: 232,
          radius: AppSurfaces.contentRadius,
        ),
        Gap(AppSpacing.betweenSections),
        AppSkeletonBox(width: 152, height: 20, radius: 7),
        Gap(AppSpacing.betweenRelated),
        _DistributionSkeleton(),
        Gap(AppSpacing.betweenSections),
        Row(
          children: [
            AppSkeletonBox(width: 132, height: 20, radius: 7),
            Spacer(),
            AppSkeletonBox(width: 52, height: 14, radius: 7),
          ],
        ),
        Gap(AppSpacing.betweenRelated),
        AppSkeletonBox(
          width: double.infinity,
          height: 158,
          radius: AppSurfaces.contentRadius,
        ),
        Gap(AppSpacing.betweenRelated),
        Row(
          children: [
            AppSkeletonBox(width: 104, height: 32, radius: 999),
            Gap(AppSpacing.titleToDescription),
            AppSkeletonBox(width: 120, height: 32, radius: 999),
          ],
        ),
      ],
    ),
  );
}

class _ProgressStatsSkeleton extends StatelessWidget {
  const _ProgressStatsSkeleton();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = AppSpacing.betweenRelated;
      final double tileWidth = (constraints.maxWidth - spacing) / 2;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (int index = 0; index < 4; index++)
            SizedBox(
              width: tileWidth,
              child: const _ProgressStatSkeletonTile(),
            ),
        ],
      );
    },
  );
}

class _ProgressStatSkeletonTile extends StatelessWidget {
  const _ProgressStatSkeletonTile();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow,
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSkeletonCircle(size: 38),
        Gap(8),
        AppSkeletonBox(height: 25, radius: 8),
        Gap(4),
        AppSkeletonBox(width: 88, height: 13, radius: 6),
      ],
    ),
  );
}

class _DistributionSkeleton extends StatelessWidget {
  const _DistributionSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: AppSurfaces.content(context.colorTokens),
    child: const Column(
      children: [
        _DistributionRowSkeleton(),
        Gap(AppSpacing.betweenRelated),
        _DistributionRowSkeleton(),
        Gap(AppSpacing.betweenRelated),
        _DistributionRowSkeleton(),
        Gap(AppSpacing.betweenRelated),
        _DistributionRowSkeleton(),
      ],
    ),
  );
}

class _DistributionRowSkeleton extends StatelessWidget {
  const _DistributionRowSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      AppSkeletonCircle(size: 32),
      Gap(AppSpacing.betweenRelated),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: AppSkeletonBox(height: 14, radius: 6)),
                Gap(20),
                AppSkeletonBox(width: 48, height: 12, radius: 6),
              ],
            ),
            Gap(AppSpacing.titleToDescription),
            AppSkeletonBox(height: 6, radius: 999),
          ],
        ),
      ),
    ],
  );
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.l10n.progressTitle, style: context.textStyles.pageTitle),
      const Gap(AppSpacing.titleToDescription),
      Text(
        context.l10n.progressSubtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.caption,
      ),
    ],
  );
}

class _DistributionCard extends StatefulWidget {
  const _DistributionCard({required this.controller});

  final ProgressController controller;

  @override
  State<_DistributionCard> createState() => _DistributionCardState();
}

class _DistributionCardState extends State<_DistributionCard> {
  static const int _collapsedItemCount = 3;

  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final List<ProgressActivitySummary> activities =
        widget.controller.selectedPeriodActivities;
    final List<ProgressActivitySummary> visibleActivities = _showAll
        ? activities
        : activities.take(_collapsedItemCount).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.content(context.colorTokens),
      child: activities.isEmpty
          ? const _DistributionEmptyState()
          : Column(
              children: [
                for (int index = 0; index < visibleActivities.length; index++)
                  _DistributionRow(
                    activity: visibleActivities[index],
                    isLast:
                        index == visibleActivities.length - 1 &&
                        (activities.length <= _collapsedItemCount || _showAll),
                  ),
                if (activities.length > _collapsedItemCount && !_showAll)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _showAll = true),
                      child: Text(context.l10n.profileSeeAll),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({required this.activity, this.isLast = false});

  final ProgressActivitySummary activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color color = activity.category.accentColor;
    final String value = activity.isReading
        ? context.l10n.metricPagesValue(activity.pages)
        : formatDurationLong(Duration(seconds: activity.seconds));
    final String share = activity.isReading
        ? context.l10n.progressActivityPagesShare(
            (activity.share * 100).round(),
          )
        : context.l10n.progressActivityTimeShare(
            (activity.share * 100).round(),
          );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.betweenRelated),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(
            icon: _categoryIcon(activity.category),
            color: color,
            size: 36,
          ),
          const Gap(AppSpacing.betweenRelated),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: context.textStyles.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.titleToDescription),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: activity.share.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const Gap(5),
                Text(share, style: context.textStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionEmptyState extends StatelessWidget {
  const _DistributionEmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        AppIconBadge(
          icon: Icons.insights_rounded,
          color: context.colorTokens.textHint,
          size: 40,
        ),
        const Gap(AppSpacing.betweenRelated),
        Text(
          context.l10n.progressActivityEmptyTitle,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(AppSpacing.titleToDescription),
        Text(
          context.l10n.progressActivityEmptyDescription,
          textAlign: TextAlign.center,
          style: context.textStyles.caption,
        ),
      ],
    ),
  );
}

IconData _categoryIcon(TimeCategoryType category) => switch (category) {
  TimeCategoryType.studying => Icons.school_rounded,
  TimeCategoryType.exercises => Icons.fitness_center_rounded,
  TimeCategoryType.reading => Icons.auto_stories_rounded,
  TimeCategoryType.hobbies => Icons.palette_rounded,
};
