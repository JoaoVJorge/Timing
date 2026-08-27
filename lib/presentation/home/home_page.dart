import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/home/home_controller.dart";
import "package:timing/presentation/home/widgets/home_action_card.dart";
import "package:timing/presentation/home/widgets/home_activity_grid.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/functions/format_name.dart";
import "package:timing/shared/functions/format_relative_time.dart";
import "package:timing/shared/functions/format_schedule_time.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_section_header.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_spacing.dart";

/// Answers "what should I do now?" and, right below it, "what am I doing
/// today?". Historical statistics live on Progress.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16),
        const _Greeting(),
        const Gap(AppSpacing.betweenSections - 4),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
            children: [
              const _HomeActionCardSection(),
              const Gap(AppSpacing.betweenSections),
              const _PlanDayRows(),
              const Gap(AppSpacing.betweenSections),
              AppSectionHeader(title: context.l10n.homeCategoriesSection),
              const Gap(AppSpacing.betweenRelated),
              const _HomeActivitiesSection(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            controller.userName.value.isEmpty
                ? context.l10n.homeGreetingDefault
                : context.l10n.homeGreetingWithName(
                    capitalizeName(controller.userName.value),
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.pageTitle,
          ),
        ),
        const Gap(AppSpacing.titleToDescription),
        Obx(
          () => Text(
            _subtitle(context, controller),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption,
          ),
        ),
        Obx(() {
          final int streak = controller.currentStreak.value;
          if (streak < 2) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.betweenRelated),
            child: _StreakChip(days: streak),
          );
        }),
      ],
    );
  }

  String _subtitle(BuildContext context, HomeController controller) {
    final int focusSeconds = controller.todayProgress.value.focusSeconds;
    if (focusSeconds > 0) {
      return context.l10n.homeSubtitleFocusedToday(
        formatDurationLong(Duration(seconds: focusSeconds)),
      );
    }
    final next = controller.nextTodayEntry;
    if (next != null) {
      return context.l10n.homeSubtitleNextSchedule(
        next.title,
        formatMinutesOfDay(context, next.startMinutes!),
      );
    }
    return context.l10n.homeSubtitleStart;
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colorTokens.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: accent, size: 18),
          const Gap(6),
          Text(
            context.l10n.homeStreakLabel(days),
            style: context.textStyles.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionCardSection extends StatelessWidget {
  const _HomeActionCardSection();

  @override
  Widget build(BuildContext context) => Obx(() {
    final HomeController controller = Get.find();
    final resumable = controller.resumableSubject;
    if (resumable != null) {
      final activity = controller.lastActivity.value;
      return HomeActionCard(
        eyebrow: context.l10n.homeActionContinueEyebrow,
        title: resumable.name,
        meta: activity == null
            ? null
            : formatRelativeTime(context, activity.timestamp),
        leadingIconName: resumable.category.iconName,
        actionIconName: "play",
        onTap: controller.onContinue,
      );
    }

    final suggested = controller.suggestedSubject;
    if (suggested != null) {
      return HomeActionCard(
        eyebrow: context.l10n.homeActionStartEyebrow,
        title: suggested.name,
        meta: context.l10n.homeActionSuggestedMeta,
        leadingIconName: suggested.category.iconName,
        actionIconName: "play",
        onTap: controller.onStartSuggested,
      );
    }

    return HomeActionCard(
      eyebrow: context.l10n.homeActionStartEyebrow,
      title: context.l10n.homeActionCreateBody,
      actionIconName: "plus",
      onTap: controller.onCreateFirstSubject,
    );
  });
}

/// Planning shortcuts. Daily goals are not an activity to track, they are
/// something you decide beforehand, so they sit here and not in the grid.
class _PlanDayRows extends StatelessWidget {
  const _PlanDayRows();

  @override
  Widget build(BuildContext context) => Obx(() {
    final HomeController controller = Get.find();
    final next = controller.nextTodayEntry;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color accent = context.colorTokens.primary;
    final Color background = isDarkMode
        ? Color.lerp(context.colorTokens.surface, accent, 0.08) ??
              context.colorTokens.surface
        : context.colorTokens.surface;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.event_note_rounded, color: accent, size: 22),
                const Gap(12),
                Expanded(
                  child: Text(
                    context.l10n.homePlanDayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.cardTitle.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              children: [
                _PlanDayRow(
                  icon: Icons.event_available_rounded,
                  title: context.l10n.homeTasksSection,
                  isLoading: controller.isLoading.value,
                  subtitle: controller.goalsTotal > 0
                      ? context.l10n.homeGoalsProgress(
                          controller.goalsDoneToday,
                          controller.goalsTotal,
                        )
                      : context.l10n.dailyGoalsEmptyTitle,
                  accent: accent,
                  onTap: controller.onTapDailyGoals,
                ),

                _PlanDayRow(
                  icon: Icons.calendar_month_rounded,
                  title: _nextCommitmentTitle(context),
                  isLoading: controller.isLoading.value,
                  subtitle: next == null
                      ? _scheduleSubtitle(context)
                      : "${_todayLabel(context)}, ${formatScheduleRange(context, next.startMinutes, next.endMinutes)}",
                  accent: accent,
                  onTap: controller.onTapSchedule,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });

  String _scheduleSubtitle(BuildContext context) =>
      context.l10n.homeScheduleRoutineSubtitle;
}

class _PlanDayRow extends StatelessWidget {
  const _PlanDayRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLoading;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.99,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(accent, Colors.white, 0.22) ?? accent,
                  accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle.copyWith(fontSize: 15),
                ),
                const Gap(3),
                if (isLoading)
                  const AppSkeleton(
                    child: AppSkeletonBox(height: 16, width: 160, radius: 4),
                  )
                else
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.caption.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
          const Gap(8),
          Icon(Icons.chevron_right_rounded, color: accent, size: 28),
        ],
      ),
    ),
  );
}

String _nextCommitmentTitle(BuildContext context) =>
    context.l10n.homeNextCommitmentTitle;

String _todayLabel(BuildContext context) => context.l10n.todayLabel;

class _HomeActivitiesSection extends StatelessWidget {
  const _HomeActivitiesSection();

  @override
  Widget build(BuildContext context) => Obx(() {
    final HomeController controller = Get.find();

    return HomeActivityGrid(
      activities: [
        for (final TimeCategoryType category in TimeCategoryType.values)
          (
            category: category,
            label: category.localizedLabel(context),
            value: _categoryValue(context, controller, category),
          ),
      ],
      onTapActivity: controller.onTapCategory,
    );
  });

  String _categoryValue(
    BuildContext context,
    HomeController controller,
    TimeCategoryType category,
  ) {
    if (!controller.hasSubjectsIn(category)) {
      return controller.emptyCategoryValue(context, category);
    }
    if (category == TimeCategoryType.reading) {
      return context.l10n.metricPagesValue(controller.pagesIn(category));
    }
    return formatDurationLong(
      Duration(seconds: controller.focusSecondsIn(category)),
    );
  }
}
