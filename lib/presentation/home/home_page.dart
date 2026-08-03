import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/home/home_controller.dart";
import "package:help_out/presentation/home/widgets/home_action_card.dart";
import "package:help_out/presentation/home/widgets/home_activity_grid.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/shared/functions/format_relative_time.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/app_section_header.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";

/// Answers "what should I do now?" and, right below it, "what am I doing
/// today?". Historical statistics live on Progress.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
    final next = controller.nextTodayEntry;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color accent = context.colorTokens.primary;
    final Color background = isDarkMode
        ? Color.lerp(context.colorTokens.surface, accent, 0.08) ??
              context.colorTokens.surface
        : context.colorTokens.surface;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? accent.withValues(alpha: 0.18)
              : context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
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
          Row(
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
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              color: context.colorTokens.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.colorTokens.borderUnfocused.withValues(
                  alpha: isDarkMode ? 0.35 : 0.55,
                ),
              ),
            ),
            child: Column(
              children: [
                _PlanDayRow(
                  icon: Icons.event_available_rounded,
                  title: context.l10n.homeTasksSection,
                  subtitle: controller.goalsTotal > 0
                      ? context.l10n.homeGoalsProgress(
                          controller.goalsDoneToday,
                          controller.goalsTotal,
                        )
                      : context.l10n.dailyGoalsEmptyTitle,
                  accent: accent,
                  onTap: controller.onTapDailyGoals,
                ),
                Divider(
                  height: 1,
                  indent: 64,
                  color: context.colorTokens.divider.withValues(alpha: 0.7),
                ),
                _PlanDayRow(
                  icon: Icons.calendar_month_rounded,
                  title: _nextCommitmentTitle(context),
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
      switch (context.languageCode) {
        "es" => "Próximos horarios y rutina semanal",
        "pt" => "Próximos horários e rotina semanal",
        _ => "Upcoming times and weekly routine",
      };
}

class _PlanDayRow extends StatelessWidget {
  const _PlanDayRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
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
    switch (context.languageCode) {
      "es" => "Próximo compromiso",
      "pt" => "Próximo compromisso",
      _ => "Next commitment",
    };

String _todayLabel(BuildContext context) => switch (context.languageCode) {
  "es" => "Hoy",
  "pt" => "Hoje",
  _ => "Today",
};

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
    if (category == TimeCategoryType.reading) {
      return context.l10n.metricPagesValue(controller.pagesIn(category));
    }
    return formatDurationLong(
      Duration(seconds: controller.focusSecondsIn(category)),
    );
  }
}
