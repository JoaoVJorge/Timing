import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/profile/profile_controller.dart";
import "package:help_out/presentation/profile/widgets/stat_card.dart";
import "package:help_out/presentation/profile/widgets/top_theme_tile.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            Text(context.l10n.profileTitle, style: context.textStyles.titleFont),
            const Gap(4),
            Obx(
              () => Text(
                controller.userName.value.isEmpty
                    ? context.l10n.profileSubtitleDefault
                    : context.l10n.profileSubtitleWithName(
                        controller.userName.value,
                      ),
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(16),
            Obx(() {
              final stats = controller.stats.value;
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 148,
                ),
                children: [
                  StatCard(
                    icon: Icons.school_outlined,
                    label: context.l10n.statHoursStudied,
                    value: formatDurationLong(
                      Duration(seconds: stats.studyingTotalSeconds),
                    ),
                  ),
                  StatCard(
                    icon: Icons.emoji_events_outlined,
                    label: context.l10n.statTopSubject,
                    value:
                        stats.topStudyingSubject?.name ??
                        context.l10n.statTopSubjectFallback,
                  ),
                  StatCard(
                    icon: Icons.work_outline,
                    label: context.l10n.statHoursWorked,
                    value: formatDurationLong(
                      Duration(seconds: stats.workingTotalSeconds),
                    ),
                  ),
                  StatCard(
                    icon: Icons.menu_book_outlined,
                    label: context.l10n.statHoursRead,
                    value: formatDurationLong(
                      Duration(seconds: stats.readingTotalSeconds),
                    ),
                  ),
                ],
              );
            }),
            const Gap(24),
            Text(context.l10n.myScheduleCardTitle, style: context.textStyles.extraBold20),
            const Gap(12),
            Obx(() {
              final List<ScheduleEntryEntity> preview = controller.sortedScheduleEntries.take(3).toList();

              return BounceTap(
                pressedScale: 0.98,
                onTap: controller.onTapSchedule,
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: context.colorTokens.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.colorTokens.borderUnfocused),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: context.colorTokens.borderUnfocused)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(context.l10n.periodToday, style: context.textStyles.extraBold20)),
                            AppIcon("right_back", size: 12, color: context.colorTokens.primary),
                          ],
                        ),
                      ),
                      if (preview.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Text(
                            context.l10n.noScheduleYet,
                            style: context.textStyles.bodyMedium.copyWith(color: context.colorTokens.textHint),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int index = 0; index < preview.length; index++) ...[
                                if (index > 0) const Gap(8),
                                _SchedulePreviewRow(entry: preview[index]),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const Gap(24),
            Text(
              context.l10n.mostReadThemes,
              style: context.textStyles.extraBold20,
            ),
            const Gap(12),
            Obx(() {
              final topReadingSubjects =
                  controller.stats.value.topReadingSubjects;

              if (topReadingSubjects.isEmpty) {
                return Text(
                  context.l10n.noReadingYet,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                );
              }

              return Column(
                children: [
                  for (
                    int index = 0;
                    index < topReadingSubjects.length;
                    index++
                  ) ...[
                    if (index > 0) const Gap(12),
                    TopThemeTile(
                      rank: index + 1,
                      subject: topReadingSubjects[index],
                    ),
                  ],
                ],
              );
            }),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

class _SchedulePreviewRow extends StatelessWidget {
  const _SchedulePreviewRow({required this.entry});

  final ScheduleEntryEntity entry;

  String _formatMinutes(BuildContext context, int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

  @override
  Widget build(BuildContext context) {
    final Color color = Color(entry.colorValue);
    final String timeRange = entry.endMinutes == null
        ? _formatMinutes(context, entry.startMinutes)
        : "${_formatMinutes(context, entry.startMinutes)} - ${_formatMinutes(context, entry.endMinutes!)}";

    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const Gap(10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "$timeRange: ",
              style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint),
              children: [TextSpan(text: entry.title, style: context.textStyles.bodyLarge)],
            ),
          ),
        ),
      ],
    );
  }
}
