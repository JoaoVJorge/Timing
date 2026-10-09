import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/category/widgets/subject_icon_badge.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/widgets/subject_comparatives_section.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/functions/format_rest_duration.dart";
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
      // Observing the activity redraws the page from zero once its data is
      // deleted.
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
          children: [
            _SubjectStatsHero(
              subject: controller.subject,
              accent: accent,
              progress: controller.progress,
              progressLabel: controller.isDaily
                  ? context.l10n.periodToday
                  : context.l10n.periodTotal,
            ),
            const Gap(AppSpacing.betweenSections),
            AppSectionHeader(title: overviewTitle(context)),
            const Gap(AppSpacing.betweenRelated),
            _StatsGrid(controller: controller, accent: accent),
            const Gap(AppSpacing.betweenSections),
            AppSectionHeader(title: comparativesTitle(context)),
            const Gap(AppSpacing.betweenRelated),
            SubjectComparativesSection(accent: accent),
            const Gap(AppSpacing.betweenSections),
            AppSectionHeader(title: context.l10n.adjustTimeSectionTitle),
            const Gap(AppSpacing.betweenRelated),
            _AdjustTimeList(controller: controller, accent: accent),
            const Gap(AppSpacing.betweenRelated + 12),
            _ClearDataButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Adds time done without the timer, or takes back time it counted by mistake.
class _AdjustTimeList extends StatelessWidget {
  const _AdjustTimeList({required this.controller, required this.accent});

  final SubjectStatsController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Obx(() {
    final bool isBusy =
        controller.isAdjustingTime.value || controller.isClearingData.value;

    return Material(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _AdjustTimeRow(
            key: const ValueKey<String>("add-subject-time"),
            icon: Icons.add_rounded,
            label: context.l10n.addTimeButtonLabel,
            subtitle: context.l10n.addTimeRowSubtitle,
            color: accent,
            onTap: isBusy ? null : controller.onAddTime,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: context.colorTokens.borderUnfocused.withValues(
                alpha: 0.55,
              ),
            ),
          ),
          _AdjustTimeRow(
            key: const ValueKey<String>("remove-subject-time"),
            icon: Icons.remove_rounded,
            label: context.l10n.removeTimeButtonLabel,
            subtitle: context.l10n.removeTimeRowSubtitle,
            color: accent,
            onTap: !isBusy && controller.canRemoveTime
                ? controller.onRemoveTime
                : null,
          ),
        ],
      ),
    );
  });
}

class _AdjustTimeRow extends StatelessWidget {
  const _AdjustTimeRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    child: InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.textStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(3),
                    Text(subtitle, style: context.textStyles.caption),
                  ],
                ),
              ),
              const Gap(8),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorTokens.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// A quiet destructive action; the existing confirmation protects the data.
class _ClearDataButton extends StatelessWidget {
  const _ClearDataButton({required this.controller});

  final SubjectStatsController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => Container(
      decoration: BoxDecoration(
        color: context.colorTokens.primaryForeground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: TextButton.icon(
        key: const ValueKey<String>("clear-subject-data"),
        onPressed:
            controller.isClearingData.value || controller.isAdjustingTime.value
            ? null
            : controller.onClearData,
        style: TextButton.styleFrom(
          foregroundColor: context.colorTokens.error,
          minimumSize: const Size(0, 48),
          textStyle: context.textStyles.caption,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: Text(context.l10n.clearDataButtonLabel),
      ),
    ),
  );
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
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progressLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.colorTokens.primary,
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
    final _StatItem goalStart = _StatItem(
      icon: Icons.calendar_month_rounded,
      value: _goalStartValue(context, controller.goalStartDate),
      label: _goalStartLabel(context),
    );
    final _StatItem activityType = _StatItem(
      icon: Icons.event_repeat_rounded,
      value: controller.isDaily
          ? context.l10n.activityTypeDailyLabel
          : context.l10n.activityTypePermanentLabel,
      label: context.l10n.activityTypeLabel,
    );
    final List<_StatItem> items = controller.isReading
        ? [
            _StatItem(
              icon: Icons.schedule_rounded,
              value: formatDurationLong(
                Duration(seconds: subject.totalSeconds),
              ),
              label: subject.category.spentTimeLabel(context),
            ),
            _StatItem(
              icon: Icons.auto_stories_rounded,
              value: context.l10n.metricPagesValue(subject.currentPages),
              label: _totalPagesReadLabel(context),
            ),
            activityType,
            goalStart,
          ]
        : [
            _StatItem(
              icon: Icons.schedule_rounded,
              value: formatDurationLong(
                Duration(seconds: subject.totalSeconds),
              ),
              label: subject.category.spentTimeLabel(context),
            ),
            goalStart,
            activityType,
            if (subject.hasRest)
              _StatItem(
                icon: Icons.local_cafe_rounded,
                value: _restValue(context, subject),
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

  String _restValue(BuildContext context, SubjectEntity subject) =>
      formatRestDuration(
        context,
        Duration(seconds: subject.restSeconds),
        usesSeconds: subject.category == TimeCategoryType.exercises,
      );

  String _goalStartValue(BuildContext context, DateTime? start) => start == null
      ? "—"
      : DateFormat.yMd(
          Localizations.localeOf(context).toString(),
        ).format(start);
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.item, required this.accent});

  final _StatItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: AppSpacing.tile,
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
          style: context.textStyles.caption,
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

String _totalPagesReadLabel(BuildContext context) =>
    context.l10n.totalPagesReadLabel;

String _goalStartLabel(BuildContext context) => context.l10n.goalStartLabel;

String _restLabel(BuildContext context) => context.l10n.restLabel;
