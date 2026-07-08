import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/profile/profile_category_style.dart";
import "package:help_out/presentation/profile/profile_controller.dart";
import "package:help_out/presentation/profile/widgets/profile_agenda_preview.dart";
import "package:help_out/presentation/profile/widgets/profile_empty_state.dart";
import "package:help_out/presentation/profile/widgets/profile_evolution.dart";
import "package:help_out/presentation/profile/widgets/profile_header.dart";
import "package:help_out/presentation/profile/widgets/profile_top_subjects_list.dart";
import "package:help_out/presentation/profile/widgets/stat_card.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/theme/avatar_presets.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(title: context.l10n.profileTitle),
      body: SingleChildScrollView(
        child: Obx(() {
          final ProfileStatsEntity stats = controller.stats.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                name: _displayName(context, controller.userName.value),
                handle: _handle(context, controller.nickName.value),
                avatarIcon: AppAvatarPresets.byIndex(
                  controller.avatarIconIndex.value,
                ),
                onTapEdit: controller.onTapEditProfile,
              ),
              const Gap(24),
              if (stats.isEmpty)
                ProfileEmptyState(
                  onStart: () =>
                      controller.onTapCategory(TimeCategoryType.studying),
                  onCreateSubject: () =>
                      controller.onTapCategory(TimeCategoryType.studying),
                  onCreateGoal: controller.onTapCreateGoal,
                  onAddSchedule: controller.onAddScheduleEntry,
                )
              else ...[
                _SummaryCard(stats: stats),
                const Gap(16),
                _StatsGrid(stats: stats, controller: controller),
                const Gap(24),
                ProfileEvolution(stats: stats),
              ],
              const Gap(24),
              ProfileAgendaPreview(
                entries: controller.sortedScheduleEntries,
                onTapSchedule: controller.onTapSchedule,
                onAddEntry: controller.onAddScheduleEntry,
              ),
              if (!stats.isEmpty) ...[
                const Gap(24),
                Text(
                  context.l10n.profileTopReadingTitle,
                  style: context.textStyles.extraBold20,
                ),
                const Gap(12),
                ProfileTopSubjectsList(subjects: stats.topReadingSubjects),
              ],
              const Gap(24),
            ],
          );
        }),
      ),
    );
  }

  String _displayName(BuildContext context, String rawName) {
    final String formatted = capitalizeName(rawName);
    return formatted.isEmpty ? context.l10n.loginNameHint : formatted;
  }

  String _handle(BuildContext context, String rawNick) {
    final String nick = rawNick.trim().replaceAll(RegExp(r"^@+\s*"), "");
    return nick.isEmpty ? "@${context.l10n.nicknameFallback}" : "@$nick";
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: context.colorTokens.primaryGradient,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.profileSummaryLabel,
          style: context.textStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const Gap(8),
        Text(
          formatDurationLong(Duration(seconds: stats.totalFocusSeconds)),
          style: context.textStyles.black32.copyWith(color: Colors.white),
        ),
        const Gap(4),
        Text(
          context.l10n.profileSummaryFocusLabel,
          style: context.textStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        const Gap(2),
        Text(
          context.l10n.profileSummaryFocusDescription,
          style: context.textStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.controller});

  final ProfileStatsEntity stats;
  final ProfileController controller;

  double? _progress(int current, int goal) =>
      goal > 0 ? current / goal : null;

  @override
  Widget build(BuildContext context) => GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      mainAxisExtent: 180,
    ),
    children: [
      ProfileStatCard(
        iconName: TimeCategoryType.studying.iconName,
        accentColor: TimeCategoryType.studying.accentColor,
        label: context.l10n.statHoursStudied,
        value: formatDurationLong(
          Duration(seconds: stats.studyingTotalSeconds),
        ),
        progress: _progress(
          stats.studyingTotalSeconds,
          stats.studyingGoalSeconds,
        ),
        isEmpty: stats.studyingTotalSeconds == 0,
        emptyTitle: context.l10n.profileStatTimeEmptyTitle,
        emptyDescription: context.l10n.profileStatTimeEmptyDescription,
        onTap: () => controller.onTapCategory(TimeCategoryType.studying),
      ),
      ProfileStatCard(
        iconName: TimeCategoryType.studying.iconName,
        accentColor: TimeCategoryType.studying.accentColor,
        label: context.l10n.statTopSubject,
        value: stats.hasTopStudyingSubject
            ? capitalizeName(stats.topStudyingSubject!.name)
            : "",
        subtitle: stats.hasTopStudyingSubject
            ? formatDurationLong(
                Duration(seconds: stats.topStudyingSubject!.totalSeconds),
              )
            : null,
        isEmpty: !stats.hasTopStudyingSubject,
        emptyTitle: context.l10n.profileTopSubjectEmptyTitle,
        emptyDescription: context.l10n.profileTopSubjectEmptyDescription,
        onTap: () => controller.onTapCategory(TimeCategoryType.studying),
      ),
      ProfileStatCard(
        iconName: TimeCategoryType.exercises.iconName,
        accentColor: TimeCategoryType.exercises.accentColor,
        label: context.l10n.statHoursExercised,
        value: formatDurationLong(
          Duration(seconds: stats.exercisesTotalSeconds),
        ),
        progress: _progress(
          stats.exercisesTotalSeconds,
          stats.exercisesGoalSeconds,
        ),
        isEmpty: stats.exercisesTotalSeconds == 0,
        emptyTitle: context.l10n.profileStatTimeEmptyTitle,
        emptyDescription: context.l10n.profileStatTimeEmptyDescription,
        onTap: () => controller.onTapCategory(TimeCategoryType.exercises),
      ),
      ProfileStatCard(
        iconName: TimeCategoryType.reading.iconName,
        accentColor: TimeCategoryType.reading.accentColor,
        label: context.l10n.statPagesRead,
        value: "${stats.readingTotalPages}",
        progress: _progress(stats.readingTotalPages, stats.readingGoalPages),
        isEmpty: stats.readingTotalPages == 0,
        emptyTitle: context.l10n.profileStatReadingEmptyTitle,
        emptyDescription: context.l10n.profileStatReadingEmptyDescription,
        onTap: () => controller.onTapCategory(TimeCategoryType.reading),
      ),
    ],
  );
}
