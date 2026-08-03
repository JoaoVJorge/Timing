import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";
import "package:help_out/presentation/schedule/widgets/schedule_date_strip.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/shared/widgets/app_empty_state.dart";
import "package:help_out/shared/widgets/app_icon.dart";
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
      topBar: AppTopBar(
        title: context.l10n.myScheduleTitle,
        showBackButton: true,
      ),
      bottomBar: _ScheduleAddButton(onTap: controller.onTapAddEntry),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _WeekLabel(),
          const Gap(AppSpacing.titleToDescription),
          Obx(
            () => ScheduleDateStrip(
              selectedDate: controller.selectedDate.value,
              onSelectDate: controller.onSelectDate,
            ),
          ),
          const Gap(AppSpacing.betweenRelated),
          Expanded(
            child: Obx(() {
              final List<ScheduleEntryEntity> entries =
                  controller.sortedEntries;

              if (entries.isEmpty) {
                return _ScheduleEmptyState(
                  onAddEntry: controller.onTapAddEntry,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(
                  top: AppSpacing.titleToDescription,
                  bottom: AppSpacing.betweenRelated,
                ),
                itemCount: entries.length,
                separatorBuilder: (context, index) =>
                    const Gap(AppSpacing.titleToDescription),
                itemBuilder: (context, index) {
                  final ScheduleEntryEntity entry = entries[index];
                  return Dismissible(
                    key: ValueKey(entry.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => controller.onDeleteEntry(entry.id),
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
                      status: controller.statusOf(entry),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel();

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime now = DateTime.now();
    final DateTime weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));

    return Text(
      context.l10n.scheduleWeekLabel(
        DateFormat("d MMMM", locale).format(weekStart),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.caption,
    );
  }
}

/// Shows a dimmed sample day so the feature explains itself before there is
/// anything in it.
class _ScheduleEmptyState extends StatelessWidget {
  const _ScheduleEmptyState({required this.onAddEntry});

  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(
      top: AppSpacing.titleToDescription,
      bottom: AppSpacing.betweenRelated,
    ),
    children: [
      AppEmptyState(
        icon: Icons.calendar_month_rounded,
        title: context.l10n.noScheduleYet,
        description: context.l10n.noScheduleYetDescription,
        preview: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.scheduleEmptyExampleLabel,
              style: context.textStyles.caption.copyWith(fontSize: 11),
            ),
            const Gap(6),
            IgnorePointer(
              child: ScheduleEntryTile(
                entry: ScheduleEntryEntity(
                  id: "schedule-example",
                  title: context.l10n.categoryStudying,
                  weekday: DateTime.now().weekday,
                  startMinutes: 8 * 60,
                  endMinutes: 9 * 60 + 30,
                  colorValue: context.colorTokens.primary.toARGB32(),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ScheduleAddButton extends StatelessWidget {
  const _ScheduleAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            "plus",
            color: context.colorTokens.primaryForeground,
            size: 20,
          ),
          const Gap(AppSpacing.betweenRelated),
          Flexible(
            child: Text(
              context.l10n.addScheduleEntryButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.black20.copyWith(
                color: context.colorTokens.primaryForeground,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
