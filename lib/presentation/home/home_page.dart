import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/home/home_controller.dart";
import "package:help_out/presentation/home/widgets/home_action_card.dart";
import "package:help_out/presentation/home/widgets/home_activity_grid.dart";
import "package:help_out/presentation/home/widgets/home_agenda_card.dart";
import "package:help_out/presentation/home/widgets/home_day_summary_line.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/shared/functions/format_relative_time.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/app_nav_row.dart";
import "package:help_out/shared/widgets/app_section_header.dart";
import "package:help_out/theme/app_spacing.dart";

/// Answers "what should I do now?" and, right below it, "what am I doing
/// today?". Historical statistics live on Progress.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.betweenSections + context.mediaQuery.padding.top,
          AppSpacing.page,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Greeting(),
            const Gap(AppSpacing.betweenSections - 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.betweenSections,
                ),
                children: [
                  const _HomeActionCardSection(),
                  const Gap(AppSpacing.betweenRelated),
                  Obx(
                    () => HomeAgendaCard(
                      entries: controller.todayScheduleEntries,
                      onTapSchedule: controller.onTapSchedule,
                    ),
                  ),
                  const Gap(AppSpacing.betweenSections),
                  AppSectionHeader(
                    title: context.l10n.homePlanDayTitle,
                    description: context.l10n.homePlanDaySubtitle,
                  ),
                  const Gap(AppSpacing.betweenRelated),
                  const _PlanDayRows(),
                  const Gap(AppSpacing.betweenSections),
                  AppSectionHeader(title: context.l10n.homeCategoriesSection),
                  const Gap(AppSpacing.betweenRelated),
                  const _HomeActivitiesSection(),
                  const Gap(AppSpacing.betweenSections),
                  const _DaySummary(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        formatMinutesOfDay(context, next.startMinutes),
      );
    }
    return context.l10n.homeSubtitleStart;
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

    return AppNavRowGroup(
      rows: [
        AppNavRow(
          icon: Icons.task_alt_rounded,
          title: context.l10n.homeTasksSection,
          subtitle: controller.goalsTotal > 0
              ? context.l10n.homeGoalsProgress(
                  controller.goalsDoneToday,
                  controller.goalsTotal,
                )
              : context.l10n.dailyGoalsEmptyTitle,
          onTap: controller.onTapDailyGoals,
        ),
        AppNavRow(
          icon: Icons.calendar_month_rounded,
          title: context.l10n.myScheduleTitle,
          subtitle: context.l10n.homePlanDaySubtitle,
          onTap: controller.onTapSchedule,
        ),
      ],
    );
  });
}

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
            meta: _categoryMeta(context, controller, category),
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
    if (category == TimeCategoryType.reading) {
      return context.l10n.metricPagesValue(controller.pagesIn(category));
    }
    return formatDurationLong(
      Duration(seconds: controller.focusSecondsIn(category)),
    );
  }

  String _categoryMeta(
    BuildContext context,
    HomeController controller,
    TimeCategoryType category,
  ) {
    final SubjectEntity? top = controller.topSubjectIn(category);
    return top == null
        ? context.l10n.homeCategoryEmpty
        : capitalizeName(top.name);
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary();

  @override
  Widget build(BuildContext context) => Obx(() {
    final HomeController controller = Get.find();

    return HomeDaySummaryLine(
      focus: formatDurationLong(
        Duration(seconds: controller.todayProgress.value.focusSeconds),
      ),
      pages: controller.todayProgress.value.pages,
      goals: controller.goalsDoneToday,
    );
  });
}
