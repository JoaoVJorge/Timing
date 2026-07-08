import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Shows the next schedule slot still to come today, or a prompt to add one.
class NextScheduleCard extends StatelessWidget {
  const NextScheduleCard({required this.entry, required this.onTap, super.key});

  final ScheduleEntryEntity? entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ScheduleEntryEntity? scheduleEntry = entry;

    return BounceTap(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 22,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheduleEntry == null
                        ? context.l10n.homeNextScheduleEmpty
                        : scheduleEntry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    scheduleEntry == null
                        ? context.l10n.homeNextScheduleAdd
                        : formatScheduleRange(
                            context,
                            scheduleEntry.startMinutes,
                            scheduleEntry.endMinutes,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Icon(
              scheduleEntry == null
                  ? Icons.add_rounded
                  : Icons.chevron_right_rounded,
              size: 24,
              color: context.colorTokens.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
