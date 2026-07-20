import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/home/home_controller.dart";
import "package:help_out/presentation/home/widgets/category_card.dart";
import "package:help_out/presentation/home/widgets/home_action_card.dart";
import "package:help_out/presentation/home/widgets/home_agenda_card.dart";
import "package:help_out/presentation/home/widgets/home_today_summary.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/shared/functions/format_relative_time.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          32 + context.mediaQuery.padding.top,
          16,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                controller.userName.value.isEmpty
                    ? context.l10n.homeGreetingDefault
                    : context.l10n.homeGreetingWithName(
                        capitalizeName(controller.userName.value),
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.extraBold24.copyWith(
                  color: context.colorTokens.primary,
                ),
              ),
            ),
            const Gap(4),
            Obx(
              () => Text(
                _subtitle(context, controller),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  const _HomeActionCardSection(),
                  const Gap(12),
                  _SectionHeader(context.l10n.homeSummaryTitle),
                  const Gap(12),
                  Obx(
                    () => HomeTodaySummary(
                      items: _summaryItems(context, controller),
                    ),
                  ),
                  const Gap(12),
                  Obx(
                    () => HomeAgendaCard(
                      entries: controller.todayScheduleEntries,
                      onTapSchedule: controller.onTapSchedule,
                      onAddEntry: controller.onAddScheduleEntry,
                    ),
                  ),
                  const Gap(24),
                  _SectionHeader(context.l10n.homeCategoriesSection),
                  const Gap(12),
                  const _HomeActivitiesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
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

  List<({IconData icon, String value, String label})> _summaryItems(
    BuildContext context,
    HomeController controller,
  ) {
    final progress = controller.todayProgress.value;
    return [
      (
        icon: Icons.schedule_rounded,
        value: formatDurationLong(Duration(seconds: progress.focusSeconds)),
        label: context.l10n.homeSummaryFocus,
      ),
      (
        icon: Icons.track_changes_rounded,
        value: "${controller.goalsDoneToday}/${controller.goalsTotal}",
        label: context.l10n.homeSummaryGoals,
      ),
      (
        icon: Icons.description_rounded,
        value: "${progress.pages}",
        label: context.l10n.homeSummaryPages,
      ),
      (
        icon: Icons.trending_up_rounded,
        value: "${progress.sessions}",
        label: context.l10n.homeSummarySessions,
      ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: context.textStyles.extraBold20);
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

class _HomeActivitiesSection extends StatelessWidget {
  const _HomeActivitiesSection();

  @override
  Widget build(BuildContext context) => Obx(() {
    final HomeController controller = Get.find();
    return Column(
      children: [
        for (final TimeCategoryType category in TimeCategoryType.values) ...[
          CategoryCard(
            iconName: category.iconName,
            label: category.localizedLabel(context),
            subtitle: _categorySubtitle(context, controller, category),
            onTap: () => controller.onTapCategory(category),
          ),
          const Gap(12),
          if (category == TimeCategoryType.studying)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CategoryCard(
                iconName: "trophy",
                label: context.l10n.homeTasksSection,
                subtitle: controller.goalsTotal > 0
                    ? context.l10n.homeGoalsProgress(
                        controller.goalsDoneToday,
                        controller.goalsTotal,
                      )
                    : context.l10n.homeCategoryEmpty,
                onTap: controller.onTapDailyGoals,
              ),
            ),
        ],
      ],
    );
  });

  String _categorySubtitle(
    BuildContext context,
    HomeController controller,
    TimeCategoryType category,
  ) {
    if (category == TimeCategoryType.reading) {
      final int pages = controller.pagesIn(category);
      return pages > 0
          ? context.l10n.metricPagesValue(pages)
          : context.l10n.homeCategoryEmpty;
    }
    return controller.hasSubjectsIn(category)
        ? formatDurationLong(
            Duration(seconds: controller.focusSecondsIn(category)),
          )
        : context.l10n.homeCategoryEmpty;
  }
}
