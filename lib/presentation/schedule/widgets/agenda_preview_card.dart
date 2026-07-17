import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class AgendaPreviewCard extends StatelessWidget {
  const AgendaPreviewCard({
    required this.entries,
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.addButtonLabel,
    required this.onTapSchedule,
    required this.onAddEntry,
    super.key,
  });

  final List<ScheduleEntryEntity> entries;
  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final String addButtonLabel;
  final VoidCallback onTapSchedule;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final String locale = Localizations.localeOf(context).toString();
    final String dayLabel = DateFormat("d", locale).format(today);
    final String monthLabel = _capitalize(DateFormat.MMM(locale).format(today));
    final Color accent = context.colorTokens.info;
    final List<ScheduleEntryEntity> preview = entries.take(2).toList();

    return BounceTap(
      pressedScale: 0.985,
      onTap: onTapSchedule,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.72),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AgendaDatePanel(
                dayLabel: dayLabel,
                monthLabel: monthLabel,
                accent: accent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _AgendaIcon(accent: accent),
                          const Gap(10),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.extraBold20.copyWith(
                                fontSize: 19,
                              ),
                            ),
                          ),
                          const Gap(10),
                          _AgendaArrowButton(accent: accent),
                        ],
                      ),
                      const Gap(12),
                      if (preview.isEmpty) ...[
                        _AgendaEmptyState(
                          title: emptyTitle,
                          description: emptyDescription,
                        ),
                        const Gap(14),
                        _AddScheduleButton(
                          label: addButtonLabel,
                          accent: accent,
                          onTap: onAddEntry,
                        ),
                      ] else
                        _AgendaEntryList(entries: preview),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : "${value[0].toUpperCase()}${value.substring(1)}";
}

class _AgendaArrowButton extends StatelessWidget {
  const _AgendaArrowButton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withValues(alpha: context.isDarkMode ? 0.14 : 0.08),
      border: Border.all(color: accent.withValues(alpha: 0.2)),
    ),
    child: Icon(Icons.arrow_forward_rounded, color: accent, size: 19),
  );
}

class _AgendaDatePanel extends StatelessWidget {
  const _AgendaDatePanel({
    required this.dayLabel,
    required this.monthLabel,
    required this.accent,
  });

  final String dayLabel;
  final String monthLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 92,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: context.isDarkMode ? 0.12 : 0.08),
      border: Border(right: BorderSide(color: accent.withValues(alpha: 0.12))),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: context.textStyles.black32.copyWith(
              color: accent,
              fontSize: 40,
              height: 1,
            ),
          ),
          const Gap(5),
          Text(
            monthLabel,
            style: context.textStyles.textButtonMedium.copyWith(
              color: accent,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class _AgendaIcon extends StatelessWidget {
  const _AgendaIcon({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withValues(alpha: context.isDarkMode ? 0.18 : 0.12),
    ),
    child: Icon(Icons.calendar_month_rounded, color: accent, size: 17),
  );
}

class _AgendaEmptyState extends StatelessWidget {
  const _AgendaEmptyState({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyLarge.copyWith(
          color: context.colorTokens.textBody,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Gap(4),
      Text(
        description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
        ),
      ),
    ],
  );
}

class _AgendaEntryList extends StatelessWidget {
  const _AgendaEntryList({required this.entries});

  final List<ScheduleEntryEntity> entries;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (int index = 0; index < entries.length; index++) ...[
        if (index > 0) const Gap(8),
        _AgendaEntryRow(entry: entries[index]),
      ],
    ],
  );
}

class _AgendaEntryRow extends StatelessWidget {
  const _AgendaEntryRow({required this.entry});

  final ScheduleEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final Color entryColor = Color(entry.colorValue);
    final String timeRange = formatScheduleRange(
      context,
      entry.startMinutes,
      entry.endMinutes,
    );

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: entryColor.withValues(
              alpha: context.isDarkMode ? 0.18 : 0.1,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            timeRange,
            style: context.textStyles.textButtonMedium.copyWith(
              color: entryColor,
              fontSize: 11,
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            entry.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textBody,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddScheduleButton extends StatelessWidget {
  const _AddScheduleButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDarkMode ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, color: accent, size: 18),
          const Gap(8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textPrimaryButton.copyWith(
                color: accent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
