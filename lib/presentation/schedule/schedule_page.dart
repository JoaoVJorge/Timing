import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Row(
            children: [
              IconButton(
                onPressed: appNavigator.back,
                icon: AppIcon("left_back", size: 20, color: context.colorTokens.primary),
              ),
              Text(context.l10n.myScheduleTitle, style: context.textStyles.titleFont),
            ],
          ),
          const Gap(4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.periodToday,
              style: context.textStyles.bodyMedium.copyWith(color: context.colorTokens.textHint),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Obx(() {
              final List<ScheduleEntryEntity> entries = controller.sortedEntries;

              return ListView.separated(
                itemCount: entries.length + 1,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) {
                  if (index == entries.length) {
                    return _AddEntryTile(onTap: controller.onTapAddEntry);
                  }

                  final ScheduleEntryEntity entry = entries[index];
                  return ScheduleEntryTile(entry: entry, onDelete: () => controller.onDeleteEntry(entry.id));
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AddEntryTile extends StatelessWidget {
  const _AddEntryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorTokens.borderUnfocused, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: context.colorTokens.primary),
          const Gap(8),
          Text(context.l10n.addScheduleEntryButton, style: context.textStyles.textButtonMedium),
        ],
      ),
    ),
  );
}
