import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/profile_stats_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/progress/progress_category_style.dart";
import "package:timing/presentation/progress/progress_controller.dart";
import "package:timing/presentation/progress/widgets/progress_achievements_section.dart";
import "package:timing/presentation/progress/widgets/progress_activity_card.dart";
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
          AppSpacing.page,
          16,
          AppSpacing.page,
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
    padding: AppSpacing.tile,
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
    padding: const EdgeInsets.all(12),
    decoration: AppSurfaces.content(context.colorTokens),
    child: const Column(
      children: [
        AppSkeletonBox(height: 82, radius: 16),
        Gap(8),
        AppSkeletonBox(height: 82, radius: 16),
        Gap(8),
        AppSkeletonBox(height: 82, radius: 16),
      ],
    ),
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

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    final List<ProgressActivitySummary> activities =
        controller.selectedPeriodActivities;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: AppSurfaces.content(context.colorTokens),
      child: activities.isEmpty
          ? const _DistributionEmptyState()
          : Column(
              children: [
                for (int index = 0; index < activities.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: context.colorTokens.borderUnfocused.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ProgressActivityCard(
                    activity: activities[index],
                    rank: index + 1,
                    onTap: () => controller.onTapActivity(activities[index]),
                  ),
                ],
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
