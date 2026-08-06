import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/theme/app_spacing.dart";

/// Where an entry sits relative to now, so the day reads as a timeline instead
/// of an undifferentiated list.
enum ScheduleEntryStatus { past, current, upcoming }

class ScheduleEntryTile extends StatelessWidget {
  const ScheduleEntryTile({
    required this.entry,
    this.status = ScheduleEntryStatus.upcoming,
    super.key,
  });

  final ScheduleEntryEntity entry;
  final ScheduleEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(entry.colorValue);
    final String timeRange = formatScheduleRange(
      context,
      entry.startMinutes,
      entry.endMinutes,
    );
    final bool isPast = status == ScheduleEntryStatus.past;
    final bool isCurrent = status == ScheduleEntryStatus.current;

    return Opacity(
      opacity: isPast ? 0.55 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: isCurrent ? Border.all(color: color, width: 1.4) : null,
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.surfaceShadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(
                  alpha: context.isDarkMode ? 0.22 : 0.12,
                ),
              ),
              child: Icon(Icons.menu_book_rounded, color: color, size: 24),
            ),
            const Gap(AppSpacing.betweenRelated),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.cardTitle.copyWith(
                            decoration: isPast
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const Gap(AppSpacing.titleToDescription),
                        _NowDot(color: color),
                      ],
                    ],
                  ),
                  Text(
                    timeRange,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.caption.copyWith(
                      color: context.colorTokens.textBody.withValues(
                        alpha: 0.72,
                      ),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowDot extends StatelessWidget {
  const _NowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
