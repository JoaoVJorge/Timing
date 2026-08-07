import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/category/widgets/subject_icon_badge.dart";
import "package:help_out/presentation/subject_stats/subject_stats_controller.dart";
import "package:help_out/presentation/subject_stats/widgets/subject_comparatives_section.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_icon_badge.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_section_header.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";
import "package:get/get.dart";

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
  });

  final SubjectEntity subject;
  final Color accent;
  final double progress;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: accent.withValues(alpha: 0.12),
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
              value: "${subject.restMinutes}m",
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

String _title(BuildContext context) => switch (context.languageCode) {
  "pt" => "Estatisticas",
  "es" => "Estadisticas",
  "fr" => "Statistiques",
  "de" => "Statistiken",
  _ => "Statistics",
};

String _studiedTimeLabel(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Tempo estudado",
      "es" => "Tiempo estudiado",
      "fr" => "Temps etudie",
      "de" => "Gelernte Zeit",
      _ => "Studied time",
    };

String _readingTimeLabel(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Tempo lido",
      "es" => "Tiempo leido",
      "fr" => "Temps lu",
      "de" => "Lesezeit",
      _ => "Reading time",
    };

String _totalPagesReadLabel(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Total de paginas",
      "es" => "Total de paginas",
      "fr" => "Total des pages",
      "de" => "Seiten gesamt",
      _ => "Total pages",
    };

String _pagesReadTodayLabel(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Paginas hoje",
      "es" => "Paginas hoy",
      "fr" => "Pages aujourd'hui",
      "de" => "Seiten heute",
      _ => "Pages today",
    };

String _goalLabel(BuildContext context) => switch (context.languageCode) {
  "pt" => "Meta",
  "es" => "Meta",
  "fr" => "Objectif",
  "de" => "Ziel",
  _ => "Goal",
};

String _sessionsLabel(BuildContext context) => switch (context.languageCode) {
  "pt" => "Sessoes",
  "es" => "Sesiones",
  "fr" => "Sessions",
  "de" => "Sitzungen",
  _ => "Sessions",
};

String _restLabel(BuildContext context) => switch (context.languageCode) {
  "pt" => "Descanso",
  "es" => "Descanso",
  "fr" => "Pause",
  "de" => "Pause",
  _ => "Rest",
};
