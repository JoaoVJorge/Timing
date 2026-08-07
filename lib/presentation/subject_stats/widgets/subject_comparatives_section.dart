import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/progress/widgets/progress_evolution_chart.dart";
import "package:help_out/presentation/subject_stats/subject_stats_controller.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// The "Comparativos" card: a Week/Month bar chart of the subject's own daily
/// history, plus the period total and how it compares to the period before.
class SubjectComparativesSection extends StatelessWidget {
  const SubjectComparativesSection({required this.accent, super.key});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final SubjectStatsController controller = Get.find();

    return Obx(() {
      final bool isMonth = controller.isMonth.value;
      final bool isReading = controller.isReading;
      final SubjectComparatives data = controller.comparatives;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: AppSurfaces.content(context.colorTokens),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodToggle(
              isMonth: isMonth,
              accent: accent,
              onSelect: (value) => controller.selectPeriod(isMonth: value),
            ),
            const Gap(12),
            _Headline(
              valueLabel: _totalLabel(context, isReading, data.currentTotal),
              unitLabel: _unitLabel(context, isReading),
              accent: accent,
            ),
            const Gap(6),
            _DeltaLine(
              currentTotal: data.currentTotal,
              previousTotal: data.previousTotal,
              accent: accent,
              isMonth: isMonth,
            ),
            const Gap(16),
            SizedBox(
              height: 168,
              child: EvolutionBarChart(
                values: data.values,
                unit: isReading
                    ? EvolutionValueUnit.pages
                    : EvolutionValueUnit.minutes,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _totalLabel(BuildContext context, bool isReading, int total) =>
      isReading
      ? context.l10n.metricPagesValue(total)
      : formatDurationLong(Duration(seconds: total));

  String _unitLabel(BuildContext context, bool isReading) =>
      isReading ? _readPagesUnit(context) : _studiedUnit(context);
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.isMonth,
    required this.accent,
    required this.onSelect,
  });

  final bool isMonth;
  final Color accent;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Expanded(
          child: _ToggleTab(
            label: context.l10n.progressPeriodWeek,
            isSelected: !isMonth,
            accent: accent,
            onTap: () => onSelect(false),
          ),
        ),
        const Gap(4),
        Expanded(
          child: _ToggleTab(
            label: context.l10n.progressPeriodMonth,
            isSelected: isMonth,
            accent: accent,
            onTap: () => onSelect(true),
          ),
        ),
      ],
    ),
  );
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    child: BounceTap(
      pressedScale: 0.95,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: AppSpacing.minTapTarget - 8,
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: _isDark(context) ? 0.22 : 0.14)
              : context.colorTokens.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium.copyWith(
            color: isSelected ? accent : context.colorTokens.textHint,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

class _Headline extends StatelessWidget {
  const _Headline({
    required this.valueLabel,
    required this.unitLabel,
    required this.accent,
  });

  final String valueLabel;
  final String unitLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) => RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    text: TextSpan(
      children: [
        TextSpan(
          text: valueLabel,
          style: context.textStyles.metricValue.copyWith(
            color: accent,
            fontSize: 26,
          ),
        ),
        TextSpan(
          text: " $unitLabel",
          style: context.textStyles.caption.copyWith(fontSize: 14),
        ),
      ],
    ),
  );
}

class _DeltaLine extends StatelessWidget {
  const _DeltaLine({
    required this.currentTotal,
    required this.previousTotal,
    required this.accent,
    required this.isMonth,
  });

  final int currentTotal;
  final int previousTotal;
  final Color accent;
  final bool isMonth;

  @override
  Widget build(BuildContext context) {
    if (previousTotal <= 0) {
      return Text(
        _noComparison(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.caption,
      );
    }

    final int percent = (((currentTotal - previousTotal) / previousTotal) * 100)
        .round();
    final Color color = percent > 0
        ? accent
        : percent < 0
        ? context.colorTokens.error
        : context.colorTokens.textHint;
    final IconData icon = percent > 0
        ? Icons.trending_up_rounded
        : percent < 0
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;
    final String sign = percent > 0 ? "+" : "";

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(6),
        Flexible(
          child: Text(
            "$sign$percent% ${_versusLabel(context, isMonth)}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

String comparativesTitle(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Comparativos",
      "es" => "Comparativos",
      "fr" => "Comparatifs",
      "de" => "Vergleiche",
      _ => "Comparisons",
    };

String overviewTitle(BuildContext context) => switch (context.languageCode) {
  "pt" => "Visao geral",
  "es" => "Vision general",
  "fr" => "Vue d'ensemble",
  "de" => "Ubersicht",
  _ => "Overview",
};

String _studiedUnit(BuildContext context) => switch (context.languageCode) {
  "pt" => "estudados",
  "es" => "estudiados",
  "fr" => "etudies",
  "de" => "gelernt",
  _ => "studied",
};

String _readPagesUnit(BuildContext context) => switch (context.languageCode) {
  "pt" => "lidas",
  "es" => "leidas",
  "fr" => "lues",
  "de" => "gelesen",
  _ => "read",
};

String _versusLabel(BuildContext context, bool isMonth) {
  if (isMonth) {
    return switch (context.languageCode) {
      "pt" => "vs mes passado",
      "es" => "vs mes pasado",
      "fr" => "vs mois dernier",
      "de" => "vs letzten Monat",
      _ => "vs last month",
    };
  }
  return switch (context.languageCode) {
    "pt" => "vs semana passada",
    "es" => "vs semana pasada",
    "fr" => "vs semaine derniere",
    "de" => "vs letzte Woche",
    _ => "vs last week",
  };
}

String _noComparison(BuildContext context) => switch (context.languageCode) {
  "pt" => "Sem periodo anterior para comparar",
  "es" => "Sin periodo anterior para comparar",
  "fr" => "Aucune periode precedente a comparer",
  "de" => "Kein Vorzeitraum zum Vergleichen",
  _ => "No previous period to compare",
};
