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
    final List<ScheduleEntryEntity> preview = entries.take(4).toList();

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
          children: [
            const _AgendaHeader(),
            const Gap(14),
            if (preview.isEmpty) ...[
              const Gap(14),
              const _EmptyAgenda(),
              const Gap(14),
              _FilledAddScheduleButton(
                label: context.l10n.homeNextScheduleAdd,
                onTap: onAddEntry,
              ),
            ] else ...[
              Divider(color: context.colorTokens.divider),
              const Gap(8),
              _AgendaGrid(entries: preview),
              const Gap(8),
              Divider(color: context.colorTokens.divider),
              const Gap(8),
              _OutlinedAddScheduleButton(
                label: context.l10n.homeNextScheduleAdd,
                onTap: onAddEntry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const _AgendaIcon(),
      const Gap(14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.homeTodayAgendaTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.black32.copyWith(
                color: context.colorTokens.textBody,
                fontSize: 21,
              ),
            ),
            const Gap(5),
            const _DateChip(),
          ],
        ),
      ),
      const Gap(12),
      const _ArrowButton(),
    ],
  );
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
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.primaryVeryLight,
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Icon(
      Icons.calendar_month_rounded,
      color: context.colorTokens.primary,
      size: 22,
    ),
  );
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String dateLabel = _capitalize(
      DateFormat("EEE, d MMM", locale).format(DateTime.now()),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        dateLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyTiny.copyWith(
          color: context.colorTokens.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : "${value[0].toUpperCase()}${value.substring(1)}";
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) => Center(
    child: AppIcon("right_back", color: context.colorTokens.primary, size: 20),
  );
}

class _AgendaGrid extends StatelessWidget {
  const _AgendaGrid({required this.entries});

  final List<ScheduleEntryEntity> entries;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = 8;
      final double tileWidth = (constraints.maxWidth - spacing) / 2;

      return Wrap(
        spacing: spacing,
        runSpacing: 8,
        children: [
          for (final ScheduleEntryEntity entry in entries)
            SizedBox(
              width: tileWidth,
              child: _AgendaEntryTile(entry: entry),
            ),
        ],
      );
    },
  );
}

class _AgendaEntryTile extends StatelessWidget {
  const _AgendaEntryTile({required this.entry});

  final ScheduleEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final String startTime = formatMinutesOfDay(context, entry.startMinutes);

    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceInnerLayer.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.42,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.primaryVeryLight,
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: context.colorTokens.primary,
              size: 17,
            ),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(2),
                Text(
                  startTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.primary,
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EmptyAgendaIcon(),
          const Gap(10),
          Text(
            context.l10n.homeNextScheduleEmpty,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold20.copyWith(
              color: context.colorTokens.textBody,
              fontSize: 16,
            ),
          ),
          const Gap(4),
          Text(
            context.l10n.profileAgendaEmptyDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyAgendaIcon extends StatelessWidget {
  const _EmptyAgendaIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 62,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.5),
          ),
        ),
        Icon(
          Icons.calendar_month_outlined,
          color: context.colorTokens.textHint.withValues(alpha: 0.5),
          size: 34,
        ),
        Positioned(
          left: -2,
          top: 10,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: context.colorTokens.primary,
            size: 20,
          ),
        ),
        Positioned(
          right: 7,
          top: 2,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: context.colorTokens.primary,
            size: 16,
          ),
        ),
        Positioned(
          right: 0,
          top: 24,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: context.colorTokens.primary,
            size: 13,
          ),
        ),
      ],
    ),
  );
}

class _OutlinedAddScheduleButton extends StatelessWidget {
  const _OutlinedAddScheduleButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _AddScheduleButtonContent(
        label: label,
        color: context.colorTokens.primary,
        height: 44,
      ),
    ),
  );
}

class _FilledAddScheduleButton extends StatelessWidget {
  const _FilledAddScheduleButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _AddScheduleButtonContent(
        label: label,
        color: context.colorTokens.primaryForeground,
        height: 48,
      ),
    ),
  );
}

class _AddScheduleButtonContent extends StatelessWidget {
  const _AddScheduleButtonContent({
    required this.label,
    required this.color,
    required this.height,
  });

  final String label;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_rounded, color: color, size: 22),
        const Gap(8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.textPrimaryButton.copyWith(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}
