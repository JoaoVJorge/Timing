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
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(title: context.l10n.profileTitle),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                controller.userName.value.isEmpty
                    ? context.l10n.profileSubtitleDefault
                    : context.l10n.profileSubtitleWithName(
                        controller.userName.value,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            Text(
              context.l10n.myScheduleCardTitle,
              style: context.textStyles.extraBold20,
            ),
            const Gap(12),
            Obx(() {
              final List<ScheduleEntryEntity> preview = controller
                  .sortedScheduleEntries
                  .take(3)
                  .toList();

              return BounceTap(
                pressedScale: 0.98,
                onTap: controller.onTapSchedule,
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorTokens.primaryVeryLight,
                        context.colorTokens.surface,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: context.colorTokens.borderUnfocused,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: context.colorTokens.primaryGradient,
                              ),
                              child: const Center(
                                child: AppIcon(
                                  "timer",
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                context.l10n.periodToday,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textStyles.extraBold20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.colorTokens.primaryVeryLight,
                              ),
                              child: AppIcon(
                                "right_back",
                                size: 12,
                                color: context.colorTokens.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (preview.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          child: Text(
                            context.l10n.noScheduleYet,
                            style: context.textStyles.bodyMedium.copyWith(
                              color: context.colorTokens.textHint,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              for (
                                int index = 0;
                                index < preview.length;
                                index++
                              ) ...[
                                if (index > 0) const Gap(8),
                                _SchedulePreviewTicket(entry: preview[index]),
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

class _SchedulePreviewTicket extends StatelessWidget {
  const _SchedulePreviewTicket({required this.entry});

  final ScheduleEntryEntity entry;

  String _formatMinutes(BuildContext context, int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

  @override
  Widget build(BuildContext context) {
    final Color color = Color(entry.colorValue);
    final String timeRange = entry.endMinutes == null
        ? _formatMinutes(context, entry.startMinutes)
        : "${_formatMinutes(context, entry.startMinutes)} - ${_formatMinutes(context, entry.endMinutes!)}";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              timeRange,
              style: context.textStyles.textButtonMedium.copyWith(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              entry.title,
              maxLines: 1,
              style: context.textStyles.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
