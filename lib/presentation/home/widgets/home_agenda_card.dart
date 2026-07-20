import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
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
    final Color accent = context.colorTokens.primary;
    final List<ScheduleEntryEntity> preview = entries.take(3).toList();

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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _AgendaIcon(accent: accent),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.homeTodayAgendaTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.extraBold20,
                      ),
                      const Gap(4),
                      _DateChip(accent: accent),
                    ],
                  ),
                ),
                const Gap(12),
                _ArrowButton(accent: accent),
              ],
            ),
            const Gap(14),
            if (preview.isEmpty) ...[
              const _EmptyAgenda(),
              const Gap(12),
              _AddScheduleButton(
                label: context.l10n.homeNextScheduleAdd,
                accent: accent,
                onTap: onAddEntry,
              ),
            ] else
              for (int index = 0; index < preview.length; index++) ...[
                if (index > 0) const Gap(8),
                _AgendaEntryRow(entry: preview[index], accent: accent),
              ],
          ],
        ),
      ),
    );
  }
}

class _AgendaIcon extends StatelessWidget {
  const _AgendaIcon({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withValues(alpha: context.isDarkMode ? 0.18 : 0.12),
    ),
    child: Icon(Icons.calendar_month_rounded, color: accent, size: 22),
  );
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String dateLabel = _capitalize(
      DateFormat("EEE, d MMM", locale).format(DateTime.now()),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDarkMode ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        dateLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyTiny.copyWith(
          color: accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : "${value[0].toUpperCase()}${value.substring(1)}";
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colorTokens.surface,
      border: Border.all(color: accent.withValues(alpha: 0.32), width: 2),
    ),
    child: Icon(Icons.arrow_forward_rounded, color: accent, size: 22),
  );
}

class _AgendaEntryRow extends StatelessWidget {
  const _AgendaEntryRow({required this.entry, required this.accent});

  final ScheduleEntryEntity entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final String timeRange = formatScheduleRange(
      context,
      entry.startMinutes,
      entry.endMinutes,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceInnerLayer.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.42,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: accent, size: 16),
          const Gap(10),
          Text(
            timeRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            width: 1,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: accent.withValues(alpha: 0.3),
          ),
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
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeNextScheduleEmpty,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(4),
        Text(
          context.l10n.profileAgendaEmptyDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
      ],
    ),
  );
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
    child: CustomPaint(
      painter: _DashedBorderPainter(
        color: accent.withValues(alpha: 0.55),
        radius: 12,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: accent, size: 20),
            const Gap(8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.textPrimaryButton.copyWith(
                  color: accent,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(border);
    final metric = path.computeMetrics().first;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const double dash = 4;
    const double gap = 4;
    double distance = 0;

    while (distance < metric.length) {
      canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
