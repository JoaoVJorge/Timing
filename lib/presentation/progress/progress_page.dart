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
                    value: controller.longestGoal?.name ?? "-",
                    label: context.l10n.progressStatLongestGoal,
                    accent: ProgressAccentColors.pink,
                  ),
                  (
                    icon: Icons.auto_stories_rounded,
                    value: controller.mainReadingSubject?.name ?? "-",
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
    final int studyingSeconds = controller.selectedPeriodSecondsFor(
      TimeCategoryType.studying,
    );
    final int exerciseSeconds = controller.selectedPeriodSecondsFor(
      TimeCategoryType.exercises,
    );
    final int readingPages = controller.selectedPeriodReadingPages;
    final int hobbySeconds = controller.selectedPeriodSecondsFor(
      TimeCategoryType.hobbies,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Column(
        children: [
          _DistributionRow(
            icon: Icons.school_rounded,
            label: context.l10n.statHoursStudied,
            value: formatDurationLong(Duration(seconds: studyingSeconds)),
            progress: _ratio(
              studyingSeconds,
              controller.selectedPeriodGoalSecondsFor(
                TimeCategoryType.studying,
              ),
            ),
            color: TimeCategoryType.studying.accentColor,
          ),
          _DistributionRow(
            icon: Icons.fitness_center_rounded,
            label: context.l10n.statHoursExercised,
            value: formatDurationLong(Duration(seconds: exerciseSeconds)),
            progress: _ratio(
              exerciseSeconds,
              controller.selectedPeriodGoalSecondsFor(
                TimeCategoryType.exercises,
              ),
            ),
            color: TimeCategoryType.exercises.accentColor,
          ),
          _DistributionRow(
            icon: Icons.auto_stories_rounded,
            label: context.l10n.statPagesRead,
            value: context.l10n.metricPagesValue(readingPages),
            progress: _ratio(
              readingPages,
              controller.selectedPeriodReadingGoalPages,
            ),
            color: TimeCategoryType.reading.accentColor,
          ),
          _DistributionRow(
            icon: Icons.palette_rounded,
            label: context.l10n.categoryHobbies,
            value: formatDurationLong(Duration(seconds: hobbySeconds)),
            progress: hobbySeconds > 0 ? 1 : 0,
            color: TimeCategoryType.hobbies.accentColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  double _ratio(int current, int goal) =>
      goal <= 0 ? 0 : (current / goal).clamp(0, 1);
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.betweenRelated),
    child: Row(
      children: [
        AppIconBadge(icon: icon, color: color, size: 32),
        const Gap(AppSpacing.betweenRelated),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: context.textStyles.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const Gap(AppSpacing.titleToDescription),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
