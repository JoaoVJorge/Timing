import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/category/widgets/subject_icon_badge.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/widgets/subject_comparatives_section.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/app_icon_badge.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_section_header.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/theme/app_spacing.dart";
import "package:timing/theme/app_surfaces.dart";

class SubjectStatsPage extends GetView<SubjectStatsController> {
  const SubjectStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colorTokens.primary;

    return AppScaffold(
      topBar: AppTopBar(title: _title(context), showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
        children: [
          _SubjectStatsHero(
            subject: controller.subject,
            accent: accent,
            progress: controller.progress,
            progressLabel: context.l10n.periodTotal,
          ),
          const Gap(AppSpacing.betweenSections),
          AppSectionHeader(title: overviewTitle(context)),
          const Gap(AppSpacing.betweenRelated),
          _StatsGrid(controller: controller, accent: accent),
          const Gap(AppSpacing.betweenSections),
          AppSectionHeader(title: comparativesTitle(context)),
          const Gap(AppSpacing.betweenRelated),
          SubjectComparativesSection(accent: accent),
        ],
      ),
    );
  }
}

class _SubjectStatsHero extends StatelessWidget {
  const _SubjectStatsHero({
    required this.subject,
    required this.accent,
    required this.progress,
    required this.progressLabel,
  });

  final SubjectEntity subject;
  final Color accent;
  final double progress;
  final String progressLabel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      children: [
        SubjectIconBadge(subject: subject, color: accent),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.cardTitle,
              ),
              const Gap(4),
              Text(
                subject.category.localizedLabel(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.caption,
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progressLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    "${(progress * 100).round()}%",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.caption.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Gap(6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: context.colorTokens.surfaceInnerLayer,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.controller, required this.accent});

  final SubjectStatsController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final SubjectEntity subject = controller.subject;
    final List<_StatItem> items = controller.isReading
        ? [
            _StatItem(
              icon: Icons.schedule_rounded,
              value: formatDurationLong(
                Duration(seconds: subject.totalSeconds),
              ),
              label: _readingTimeLabel(context),
            ),
            _StatItem(
              icon: Icons.auto_stories_rounded,
              value: context.l10n.metricPagesValue(subject.currentPages),
              label: _totalPagesReadLabel(context),
            ),
            _StatItem(
              icon: Icons.today_rounded,
              value: context.l10n.metricPagesValue(controller.pagesReadToday),
              label: _pagesReadTodayLabel(context),
            ),
            _StatItem(
              icon: Icons.flag_rounded,
              value:
                  "${controller.goalPercent(subject.currentPages, subject.goalPages)}%",
              label: _goalLabel(context),
            ),
          ]
        : [
            _StatItem(
              icon: Icons.schedule_rounded,
              value: formatDurationLong(
                Duration(seconds: subject.totalSeconds),
              ),
              label: _studiedTimeLabel(context),
            ),
            _StatItem(
              icon: Icons.flag_rounded,
              value:
                  "${controller.goalPercent(subject.totalSeconds, subject.totalGoalSeconds)}%",
              label: _goalLabel(context),
            ),
            _StatItem(
              icon: Icons.timer_rounded,
              value: "${subject.focusSessionCount}",
              label: _sessionsLabel(context),
            ),
            _StatItem(
              icon: Icons.local_cafe_rounded,
              value: "${subject.restMinutes} min",
              label: _restLabel(context),
            ),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = AppSpacing.betweenRelated;
        final double tileWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final _StatItem item in items)
              SizedBox(
                width: tileWidth,
                child: _StatTile(item: item, accent: accent),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.item, required this.accent});

  final _StatItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(icon: item.icon, color: accent, size: 38),
        const Gap(10),
        Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.metricValue.copyWith(
            color: accent,
            fontSize: 22,
          ),
        ),
        const Gap(4),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption.copyWith(fontSize: 13),
        ),
      ],
    ),
  );
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

String _title(BuildContext context) => context.l10n.statisticsTitle;

String _studiedTimeLabel(BuildContext context) => context.l10n.studiedTimeLabel;

String _readingTimeLabel(BuildContext context) => context.l10n.readingTimeLabel;

String _totalPagesReadLabel(BuildContext context) =>
    context.l10n.totalPagesReadLabel;

String _pagesReadTodayLabel(BuildContext context) =>
    context.l10n.pagesReadTodayLabel;

String _goalLabel(BuildContext context) => context.l10n.goalLabel;

String _sessionsLabel(BuildContext context) => context.l10n.sessionsLabel;

String _restLabel(BuildContext context) => context.l10n.restLabel;
