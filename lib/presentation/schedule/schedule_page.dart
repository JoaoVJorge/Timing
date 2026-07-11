import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/presentation/schedule/widgets/weekday_selector.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

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
          Obx(
            () => WeekdaySelector(
              selectedWeekday: controller.selectedWeekday.value,
              onSelectWeekday: controller.onSelectWeekday,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Obx(() {
              final List<ScheduleEntryEntity> entries =
                  controller.sortedEntries;

              if (entries.isEmpty) {
                return const _ScheduleEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                itemCount: entries.length,
                separatorBuilder: (context, index) => const Gap(8),
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

class _ScheduleEmptyState extends StatelessWidget {
  const _ScheduleEmptyState();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isDarkMode
                  ? "assets/images/calendar_dark.png"
                  : "assets/images/calendar.png",
              width: 168,
              height: 168,
              fit: BoxFit.contain,
            ),
            const Gap(12),
            Text(
              context.l10n.noScheduleYet,
              textAlign: TextAlign.center,
              style: context.textStyles.extraBold24.copyWith(fontSize: 21),
            ),
            const Gap(8),
            Text(
              context.l10n.noScheduleYetDescription,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.textHint,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      height: 58,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.primary.withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon("plus", color: context.colorTokens.white, size: 24),
          const Gap(12),
          Flexible(
            child: Text(
              context.l10n.addScheduleEntryButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textPrimaryButton.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
