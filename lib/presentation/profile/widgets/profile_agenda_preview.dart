import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/widgets/agenda_preview_card.dart";

/// Summary of today's schedule shown on the Profile screen. Shows a dated
/// header, a short preview of upcoming entries and a shortcut to the agenda.
class ProfileAgendaPreview extends StatelessWidget {
  const ProfileAgendaPreview({
    required this.entries,
    required this.onTapSchedule,
    required this.onAddEntry,
    super.key,
  });

  final List<ScheduleEntryEntity> entries;
  final VoidCallback onTapSchedule;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) => AgendaPreviewCard(
    entries: entries,
    title: context.l10n.profileAgendaTitle,
    emptyTitle: context.l10n.profileAgendaEmptyTitle,
    emptyDescription: context.l10n.profileAgendaEmptyDescription,
    addButtonLabel: context.l10n.profileAgendaAddButton,
    onTapSchedule: onTapSchedule,
    onAddEntry: onAddEntry,
  );
}
