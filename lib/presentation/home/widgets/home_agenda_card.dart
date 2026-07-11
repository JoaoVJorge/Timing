import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class HomeAgendaCard extends StatelessWidget {
  const HomeAgendaCard({
    required this.entries,
    required this.onTapSchedule,
    required this.onAddEntry,
    super.key,
  });

  final List<ScheduleEntryEntity> entries;
  final VoidCallback onTapSchedule;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String dateLabel = _capitalize(
      DateFormat("EEEE, d MMM", locale).format(DateTime.now()),
    );
    final List<ScheduleEntryEntity> preview = entries.take(3).toList();

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorTokens.primaryVeryLight,
            context.colorTokens.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BounceTap(
            pressedScale: 0.98,
            onTap: onTapSchedule,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: context.colorTokens.primaryGradient,
                    ),
                    child: const Center(
                      child: AppIcon("schedule", size: 20, color: Colors.white),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.homeNextScheduleTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.extraBold20,
                        ),
                        Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colorTokens.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colorTokens.primaryVeryLight,
                    ),
                    child: AppIcon(
                      "right_back",
                      size: 12,
                      color: context.colorTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (preview.isEmpty)
            _EmptyAgenda(onAddEntry: onAddEntry)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (int index = 0; index < preview.length; index++) ...[
                    if (index > 0) const Gap(8),
                    _SchedulePreviewTicket(entry: preview[index]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : "${value[0].toUpperCase()}${value.substring(1)}";
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda({required this.onAddEntry});

  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeNextScheduleEmpty,
          style: context.textStyles.bodyLarge,
        ),
        const Gap(4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            context.l10n.profileAgendaEmptyDescription,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
        ),
        const Gap(12),
        BounceTap(
          onTap: onAddEntry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: context.colorTokens.primaryGradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon("plus", size: 14, color: Colors.white),
                const Gap(8),
                Text(
                  context.l10n.homeNextScheduleAdd,
                  style: context.textStyles.textPrimaryButton.copyWith(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SchedulePreviewTicket extends StatelessWidget {
  const _SchedulePreviewTicket({required this.entry});

  final ScheduleEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(entry.colorValue);
    final String timeRange = formatScheduleRange(
      context,
      entry.startMinutes,
      entry.endMinutes,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colorTokens.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              timeRange,
              style: context.textStyles.textButtonMedium.copyWith(
                color: color,
                fontSize: 12,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              entry.title,
              maxLines: 1,
              style: context.textStyles.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
