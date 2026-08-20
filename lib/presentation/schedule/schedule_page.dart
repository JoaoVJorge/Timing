import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";
import "package:timing/presentation/schedule/widgets/schedule_date_strip.dart";
import "package:timing/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/swipe_reveal_actions.dart";
import "package:timing/shared/functions/format_calendar_labels.dart";
import "package:timing/theme/app_spacing.dart";

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.find();

    return AppScaffold(
      topBar: Obx(() {
        final DateTime selectedDate = controller.selectedDate.value;
        return AppTopBar(
          title: formatStackedMonthYearTitle(
            Localizations.localeOf(context).toString(),
            selectedDate,
          ),
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
              child: Obx(() {
                // The strip receives callbacks that read the schedule entries
                // during its own build, so touch the list here too to keep its
                // day markers in sync after add/delete operations.
                controller.entries.length;
                return ScheduleDateStrip(
                  selectedDate: controller.selectedDate.value,
                  onSelectDate: controller.onSelectDate,
                  onMonthChanged: controller.onChangeMonth,
                  hasEntryForDate: controller.hasEntriesForDate,
                  eventColorsForDate: controller.entryColorsForDate,
                );
              }),
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
                onEditEntry: controller.onEditEntry,
                onAddEntry: controller.onTapAddEntry,
                scrollController: scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthYearPicker(
    BuildContext context,
    ScheduleController controller,
  ) async {
    final DateTime selectedDate = controller.selectedDate.value;
    final ({int year, int month})? result =
        await showDialog<({int year, int month})>(
          context: context,
          builder: (context) =>
              _MonthYearPickerDialog(initialDate: selectedDate),
        );
    if (result == null) {
      return;
    }
    controller.onSelectMonth(result.year, result.month);
  }
}

class _DayEventsPanel extends StatelessWidget {
  const _DayEventsPanel({
    required this.selectedDate,
    required this.entries,
    required this.statusOf,
    required this.onDeleteEntry,
    required this.onEditEntry,
    required this.onAddEntry,
    required this.scrollController,
  });

  final DateTime selectedDate;
  final List<ScheduleEntryEntity> entries;
  final ScheduleEntryStatus Function(ScheduleEntryEntity entry) statusOf;
  final ValueChanged<String> onDeleteEntry;
  final ValueChanged<ScheduleEntryEntity> onEditEntry;
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
                          dateLabel: formatFullDateLabel(locale, selectedDate),
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
                      return SwipeRevealActions(
                        key: ValueKey(entry.id),
                        actions: [
                          SwipeRevealAction(
                            iconData: Icons.edit_rounded,
                            background: context.colorTokens.surface,
                            iconColor: Color(entry.colorValue),
                            borderColor: context.colorTokens.borderUnfocused,
                            onTap: () => onEditEntry(entry),
                          ),
                          SwipeRevealAction(
                            iconPath: "trash",
                            background: context.colorTokens.error,
                            iconColor: context.colorTokens.white,
                            onTap: () => onDeleteEntry(entry.id),
                          ),
                        ],
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
              context.l10n.scheduleDayEventsTitle,
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon("plus", size: 16, color: context.colorTokens.primary),
          const Gap(8),
          Flexible(
            child: Text(
              context.l10n.addScheduleEntryButton,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ),
        ],
      ),
    ),
  );
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
                      formatShortMonthLabel(locale, _year, month),
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
                    label: context.l10n.cancelButton,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Gap(18),
                Expanded(
                  child: _MonthPickerConfirmButton(
                    label: context.l10n.confirmButton,
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
