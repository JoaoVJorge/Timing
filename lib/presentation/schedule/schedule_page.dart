import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/presentation/schedule/widgets/weekday_selector.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/app_button.dart";

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
      bottomBar: AppButton(
        label: context.l10n.addScheduleEntryButton,
        onTap: controller.onTapAddEntry,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => WeekdaySelector(
              selectedWeekday: controller.selectedWeekday.value,
              onSelectWeekday: controller.onSelectWeekday,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Obx(() {
              final List<ScheduleEntryEntity> entries =
                  controller.sortedEntries;

              if (entries.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.l10n.noScheduleYet,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (context, index) => const Gap(12),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    child: ScheduleEntryTile(entry: entry),
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
