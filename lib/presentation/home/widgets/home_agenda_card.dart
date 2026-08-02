import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class HomeAgendaCard extends StatelessWidget {
  const HomeAgendaCard({
    required this.entries,
    required this.onTapSchedule,
    super.key,
  });

  final List<ScheduleEntryEntity> entries;
  final VoidCallback onTapSchedule;

  @override
  Widget build(BuildContext context) {
    final ScheduleEntryEntity? next = entries.isEmpty ? null : entries.first;

    return BounceTap(
      pressedScale: 0.985,
      onTap: onTapSchedule,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.surfaceShadow,
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _AgendaIcon(),
                const Gap(14),
                Expanded(
                  child: next == null
                      ? const _EmptyAgenda()
                      : _NextAgendaEntry(entry: next),
                ),
                const Gap(12),
                const _ArrowButton(),
              ],
            ),
            const Gap(12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                next == null
                    ? _planDayLabel(context)
                    : _viewAgendaLabel(context),
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _viewAgendaLabel(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Ver agenda",
        "pt" => "Ver agenda",
        _ => "View schedule",
      };

  String _planDayLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Planificar mi dia",
    "pt" => "Planejar meu dia",
    _ => "Plan my day",
  };
}

class _NextAgendaEntry extends StatelessWidget {
  const _NextAgendaEntry({required this.entry});

  final ScheduleEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final String timeRange = formatScheduleRange(
      context,
      entry.startMinutes,
      entry.endMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption.copyWith(
            color: context.colorTokens.textHint,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(3),
        Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.cardTitle.copyWith(fontSize: 16),
        ),
        const Gap(3),
        Text(
          "${_todayLabel(context)}, $timeRange",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Proximo compromiso",
    "pt" => "Proximo compromisso",
    _ => "Next commitment",
  };

  String _todayLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Hoy",
    "pt" => "Hoje",
    _ => "Today",
  };
}

class _AgendaIcon extends StatelessWidget {
  const _AgendaIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colorTokens.primaryVeryLight,
      border: Border.all(color: context.colorTokens.primaryVeryLight),
    ),
    child: Icon(
      Icons.calendar_month_rounded,
      color: context.colorTokens.primary,
      size: 22,
    ),
  );
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _title(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.cardTitle.copyWith(fontSize: 16),
      ),
      const Gap(4),
      Text(
        _description(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.caption.copyWith(fontSize: 12),
      ),
    ],
  );

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Tu dia esta libre",
    "pt" => "Seu dia esta livre",
    _ => "Your day is free",
  };

  String _description(BuildContext context) => switch (context.languageCode) {
    "es" => "Planifica un horario para mantener tu rutina.",
    "pt" => "Planeje um horario para manter sua rotina.",
    _ => "Plan a time to keep your routine.",
  };
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) => Center(
    child: AppIcon("right_back", color: context.colorTokens.primary, size: 20),
  );
}
