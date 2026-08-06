import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/daily_progress_entity.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/services/daily_progress/subject_daily_history_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/progress/widgets/progress_evolution_chart.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// The "Comparativos" card: a Week/Month bar chart of the subject's own daily
/// history, plus the period total and how it compares to the period before.
class SubjectComparativesSection extends StatefulWidget {
  const SubjectComparativesSection({
    required this.subject,
    required this.accent,
    super.key,
  });

  final SubjectEntity subject;
  final Color accent;

  @override
  State<SubjectComparativesSection> createState() =>
      _SubjectComparativesSectionState();
}

class _SubjectComparativesSectionState
    extends State<SubjectComparativesSection> {
  final SubjectDailyHistoryService _history =
      Get.find<SubjectDailyHistoryService>();
  bool _isMonth = false;

  int get _days => _isMonth ? 30 : 7;

  bool get _isReading => widget.subject.category == TimeCategoryType.reading;

  @override
  Widget build(BuildContext context) {
    final List<DailyProgressEntity> full = _history.historyForLastDays(
      widget.subject.id,
      _days * 2,
    );
    final List<int> current = [
      for (final DailyProgressEntity day in full.sublist(_days)) _metric(day),
    ];
    final int currentTotal = current.fold(0, (sum, value) => sum + value);
    final int previousTotal = full
        .sublist(0, _days)
        .fold(0, (sum, day) => sum + _metric(day));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodToggle(
            isMonth: _isMonth,
            accent: widget.accent,
            onSelect: (isMonth) => setState(() => _isMonth = isMonth),
          ),
          const Gap(16),
          _Headline(
            valueLabel: _totalLabel(currentTotal),
            unitLabel: _unitLabel(context),
            accent: widget.accent,
          ),
          const Gap(6),
          _DeltaLine(
            currentTotal: currentTotal,
            previousTotal: previousTotal,
            accent: widget.accent,
            isMonth: _isMonth,
          ),
          const Gap(16),
          SizedBox(
            height: 168,
            child: EvolutionBarChart(
              values: current,
              unit: _isReading
                  ? EvolutionValueUnit.pages
                  : EvolutionValueUnit.minutes,
            ),
          ),
        ],
      ),
    );
  }

  int _metric(DailyProgressEntity day) =>
      _isReading ? day.pages : day.focusSeconds;

  String _totalLabel(int total) => _isReading
      ? context.l10n.metricPagesValue(total)
      : formatDurationLong(Duration(seconds: total));

  String _unitLabel(BuildContext context) =>
      _isReading ? _readPagesUnit(context) : _studiedUnit(context);
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
    decoration: BoxDecoration(
      border: Border.all(
        color: context.colorTokens.surfaceInnerLayer.withValues(
          alpha: _isDark(context) ? 0.5 : 0.7,
        ),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
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
              : context.colorTokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: context.colorTokens.borderUnfocused.withValues(
                    alpha: 0.65,
                  ),
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium.copyWith(
            color: isSelected ? accent : context.colorTokens.textHint,
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
  Widget build(BuildContext context) {
    final TextStyle headlineStyle = DefaultTextStyle.of(
      context,
    ).style.merge(
      context.textStyles.extraBold24.copyWith(color: accent),
    );

    return Row(
      children: [
        Flexible(
          child: Text(
            valueLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: headlineStyle,
          ),
        ),
        const Gap(4),
        Text(
          unitLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: headlineStyle.copyWith(color: context.colorTokens.textHint),
        ),
      ],
    );
  }
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
            style: context.textStyles.caption.copyWith(
              color: color,
            ),
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
