import "dart:ui";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";
import "package:help_out/presentation/schedule/widgets/schedule_date_strip.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:intl/intl.dart";

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.find();

    return AppScaffold(
      topBar: Obx(() {
        final DateTime selectedDate = controller.selectedDate.value;
        return AppTopBar(
          title: _monthLabel(context, selectedDate),
          showBackButton: true,
          onTitleTap: () => _showMonthYearPicker(context, controller),
        );
      }),
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Obx(
                () => ScheduleDateStrip(
                  selectedDate: controller.selectedDate.value,
                  onSelectDate: controller.onSelectDate,
                  hasEntryForDate: controller.hasEntriesForDate,
                  eventColorsForDate: controller.entryColorsForDate,
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.43,
            minChildSize: 0.32,
            maxChildSize: 0.98,
            snap: true,
            snapSizes: const [0.43, 0.98],
            builder: (context, scrollController) => Obx(
              () => _DayEventsPanel(
                selectedDate: controller.selectedDate.value,
                entries: controller.sortedEntries,
                statusOf: controller.statusOf,
                onDeleteEntry: controller.onDeleteEntry,
                onAddEntry: controller.onTapAddEntry,
                scrollController: scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayEventsPanel extends StatelessWidget {
  const _DayEventsPanel({
    required this.selectedDate,
    required this.entries,
    required this.statusOf,
    required this.onDeleteEntry,
    required this.onAddEntry,
    required this.scrollController,
  });

  final DateTime selectedDate;
  final List<ScheduleEntryEntity> entries;
  final ScheduleEntryStatus Function(ScheduleEntryEntity entry) statusOf;
  final ValueChanged<String> onDeleteEntry;
  final VoidCallback onAddEntry;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.surfaceShadow.withValues(alpha: 0.18),
              blurRadius: 26,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: ColoredBox(
            color: context.colorTokens.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                10,
                AppSpacing.page,
                0,
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 34,
                            height: 5,
                            decoration: BoxDecoration(
                              color: context.colorTokens.textHint.withValues(
                                alpha: 0.42,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Gap(20),
                        _DayEventsHeader(
                          dateLabel: _selectedDateLabel(locale, selectedDate),
                        ),
                        const Gap(20),
                      ],
                    ),
                  ),
                  SliverList.separated(
                    itemCount: entries.length + 1,
                    separatorBuilder: (context, index) =>
                        const Gap(AppSpacing.titleToDescription),
                    itemBuilder: (context, index) {
                      if (index == entries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _InlineAddScheduleButton(onTap: onAddEntry),
                        );
                      }

                      final ScheduleEntryEntity entry = entries[index];
                      return Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => onDeleteEntry(entry.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: context.colorTokens.error,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: context.colorTokens.white,
                          ),
                        ),
                        child: ScheduleEntryTile(
                          entry: entry,
                          status: statusOf(entry),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayEventsHeader extends StatelessWidget {
  const _DayEventsHeader({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorTokens.primaryVeryLight,
        ),
        child: Icon(
          Icons.calendar_month_rounded,
          color: context.colorTokens.primary,
          size: 25,
        ),
      ),
      const Gap(12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(2),
            Text(
              _dayEventsTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.caption.copyWith(
                color: context.colorTokens.textBody,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _InlineAddScheduleButton extends StatelessWidget {
  const _InlineAddScheduleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: CustomPaint(
      painter: _DashedBorderPainter(context.colorTokens.divider),
      child: Container(
        width: double.infinity,
        height: 68,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: context.colorTokens.textBody),
            const Gap(6),
            Text(
              context.l10n.addScheduleEntryButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textBody,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _monthLabel(BuildContext context, DateTime selectedDate) {
  final String locale = Localizations.localeOf(context).toString();
  final String raw = DateFormat.yMMMM(locale).format(selectedDate);
  if (raw.isEmpty) {
    return raw;
  }
  return raw.replaceFirst(raw[0], raw[0].toUpperCase());
}

Future<void> _showMonthYearPicker(
  BuildContext context,
  ScheduleController controller,
) async {
  final DateTime selectedDate = controller.selectedDate.value;
  final ({int year, int month})? result =
      await showDialog<({int year, int month})>(
        context: context,
        builder: (context) => _MonthYearPickerDialog(initialDate: selectedDate),
      );
  if (result == null) {
    return;
  }
  controller.onSelectMonth(result.year, result.month);
}

String _selectedDateLabel(String locale, DateTime selectedDate) {
  final String raw = DateFormat.MMMMEEEEd(locale).format(selectedDate);
  if (raw.isEmpty) {
    return raw;
  }
  return raw.replaceFirst(raw[0], raw[0].toUpperCase());
}

String _dayEventsTitle(BuildContext context) => switch (context.languageCode) {
  "pt" => "Eventos do dia",
  "es" => "Eventos del dia",
  "fr" => "Evenements du jour",
  "de" => "Termine des Tages",
  _ => "Day events",
};

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final Path path = Path()..addRRect(rect);
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final Path extractPath = metric.extractPath(
          distance,
          (distance + 7).clamp(0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += 13;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year = widget.initialDate.year;
  late int _month = widget.initialDate.month;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return Dialog(
      backgroundColor: context.colorTokens.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: context.colorTokens.primary,
                ),
                Expanded(
                  child: Text(
                    "$_year",
                    textAlign: TextAlign.center,
                    style: context.textStyles.extraBold24.copyWith(
                      color: context.colorTokens.dialogText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _year++),
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: context.colorTokens.primary,
                ),
              ],
            ),
            const Gap(12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 44,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final int month = index + 1;
                final bool isSelected = month == _month;
                return BounceTap(
                  onTap: () => setState(() => _month = month),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colorTokens.primary
                          : context.colorTokens.surfaceInnerLayer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _shortMonthLabel(locale, month),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? context.colorTokens.primaryForeground
                            : context.colorTokens.dialogText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: _MonthPickerTextButton(
                    label: _cancelLabel(context),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Gap(18),
                Expanded(
                  child: _MonthPickerConfirmButton(
                    label: _confirmLabel(context),
                    onPressed: () =>
                        Navigator.of(context).pop((year: _year, month: _month)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortMonthLabel(String locale, int month) {
    final String raw = DateFormat.MMM(locale).format(DateTime(_year, month));
    if (raw.isEmpty) {
      return raw;
    }
    return raw.replaceFirst(raw[0], raw[0].toUpperCase());
  }
}

class _MonthPickerTextButton extends StatelessWidget {
  const _MonthPickerTextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onPressed,
    child: Container(
      height: 48,
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          color: context.colorTokens.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _MonthPickerConfirmButton extends StatelessWidget {
  const _MonthPickerConfirmButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: onPressed,
    child: Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.textPrimaryButton.copyWith(
          color: context.colorTokens.primaryForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

String _cancelLabel(BuildContext context) => switch (context.languageCode) {
  "pt" => "Cancelar",
  "es" => "Cancelar",
  "fr" => "Annuler",
  "de" => "Abbrechen",
  _ => "Cancel",
};

String _confirmLabel(BuildContext context) => switch (context.languageCode) {
  "pt" => "Confirmar",
  "es" => "Confirmar",
  "fr" => "Confirmer",
  "de" => "Bestätigen",
  _ => "Confirm",
};
