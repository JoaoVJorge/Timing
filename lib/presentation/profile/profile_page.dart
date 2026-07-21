import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/profile/profile_category_style.dart";
import "package:help_out/presentation/profile/profile_controller.dart";
import "package:help_out/presentation/profile/widgets/profile_top_subjects_list.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/avatar_presets.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Obx(() {
          final ProfileStatsEntity stats = controller.stats.value;
          final ProfilePeriod selectedPeriod = controller.selectedPeriod.value;
          final String name = _displayName(context, controller.userName.value);
          final String handle = _handle(context, controller.nickName.value);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileTopBar(onTapSettings: controller.onTapEditProfile),
              const Gap(18),
              _IdentityHeader(
                name: name,
                handle: handle,
                avatarIcon: AppAvatarPresets.byIndex(
                  controller.avatarIconIndex.value,
                ),
                onTapEdit: controller.onTapEditProfile,
              ),
              const Gap(18),
              _FocusHeroCard(stats: stats),
              const Gap(14),
              _PeriodTabs(
                selectedPeriod: selectedPeriod,
                onSelectPeriod: controller.onSelectPeriod,
              ),
              const Gap(16),
              _HighlightsGrid(stats: stats),
              const Gap(20),
              _ProgressSection(stats: stats),
              const Gap(20),
              _EvolutionSection(values: controller.evolutionFocusSeconds),
              const Gap(20),
              _AchievementsSection(
                stats: stats,
                onTapSeeAll: controller.onTapAchievements,
              ),
              const Gap(20),
              _ReadingSection(stats: stats),
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

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onTapSettings});

  final VoidCallback onTapSettings;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.l10n.profileTitle,
          style: context.textStyles.extraBold24,
        ),
      ),
      BounceTap(
        onTap: onTapSettings,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.surface,
            border: Border.all(color: context.colorTokens.borderUnfocused),
          ),
          child: Icon(
            Icons.settings_rounded,
            size: 18,
            color: context.colorTokens.textBody,
          ),
        ),
      ),
    ],
  );
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.name,
    required this.handle,
    required this.avatarIcon,
    required this.onTapEdit,
  });

  final String name;
  final String handle;
  final IconData avatarIcon;
  final VoidCallback onTapEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: context.colorTokens.primaryGradient,
          border: Border.all(color: context.colorTokens.surface, width: 3),
        ),
        child: Icon(
          avatarIcon,
          color: context.colorTokens.primaryForeground,
          size: 30,
        ),
      ),
      const Gap(14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.extraBold20,
            ),
            Text(
              handle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(6),
            BounceTap(
              onTap: onTapEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: context.colorTokens.primaryVeryLight,
                  ),
                ),
                child: Text(
                  context.l10n.editButton,
                  style: context.textStyles.bodyTiny.copyWith(
                    color: context.colorTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FocusHeroCard extends StatelessWidget {
  const _FocusHeroCard({required this.stats});

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: context.colorTokens.primaryGradient,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.profileSummarySinceStartLabel,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primaryForeground.withValues(
                    alpha: 0.76,
                  ),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(8),
              Text(
                formatDurationLong(Duration(seconds: stats.totalFocusSeconds)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black32.copyWith(
                  color: context.colorTokens.primaryForeground,
                ),
              ),
              const Gap(2),
              Text(
                context.l10n.profileSummaryFocusLabel,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primaryForeground.withValues(
                    alpha: 0.82,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.primaryForeground.withValues(
              alpha: 0.18,
            ),
          ),
          child: Icon(
            Icons.track_changes_rounded,
            color: context.colorTokens.primaryForeground,
            size: 34,
          ),
        ),
      ],
    ),
  );
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({
    required this.selectedPeriod,
    required this.onSelectPeriod,
  });

  final ProfilePeriod selectedPeriod;
  final ValueChanged<ProfilePeriod> onSelectPeriod;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
    ),
    child: Row(
      children: [
        for (int index = 0; index < ProfilePeriod.values.length; index++) ...[
          if (index > 0) const Gap(6),
          Expanded(
            child: _PeriodTab(
              period: ProfilePeriod.values[index],
              isSelected: selectedPeriod == ProfilePeriod.values[index],
              onTap: () => onSelectPeriod(ProfilePeriod.values[index]),
            ),
          ),
        ],
      ],
    ),
  );
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  final ProfilePeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.95,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 42,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        period.localizedLabel(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.textHint,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _HighlightsGrid extends StatelessWidget {
  const _HighlightsGrid({required this.stats});

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) => GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      mainAxisExtent: 116,
    ),
    children: [
      _HighlightTile(
        icon: Icons.schedule_rounded,
        color: context.colorTokens.primary,
        value: formatDurationLong(Duration(seconds: stats.totalFocusSeconds)),
        label: context.l10n.profileSummaryFocusLabel,
      ),
      _HighlightTile(
        icon: Icons.menu_book_rounded,
        color: TimeCategoryType.studying.accentColor,
        value: stats.hasTopStudyingSubject
            ? capitalizeName(stats.topStudyingSubject!.name)
            : context.l10n.profileTopSubjectEmptyTitle,
        label: context.l10n.statTopSubject,
      ),
      _HighlightTile(
        icon: Icons.local_fire_department_rounded,
        color: context.colorTokens.warning,
        value: formatDurationLong(
          Duration(seconds: stats.exercisesTotalSeconds),
        ),
        label: context.l10n.statHoursExercised,
      ),
      _HighlightTile(
        icon: Icons.trending_up_rounded,
        color: context.colorTokens.primary,
        value: "${stats.readingTotalPages}",
        label: context.l10n.statPagesRead,
      ),
    ],
  );
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBadge(icon: icon, color: color),
        const Spacer(),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.black20.copyWith(
            color: context.colorTokens.textBody,
          ),
        ),
        const Gap(2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
      ],
    ),
  );
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.stats});

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.profileProgressSectionTitle,
        style: context.textStyles.extraBold20,
      ),
      const Gap(12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(context),
        child: Column(
          children: [
            _ProgressRow(
              icon: Icons.school_rounded,
              label: context.l10n.statHoursStudied,
              value: formatDurationLong(
                Duration(seconds: stats.studyingTotalSeconds),
              ),
              progress: _ratio(
                stats.studyingTotalSeconds,
                stats.studyingGoalSeconds,
              ),
              color: TimeCategoryType.studying.accentColor,
            ),
            _ProgressRow(
              icon: Icons.fitness_center_rounded,
              label: context.l10n.statHoursExercised,
              value: formatDurationLong(
                Duration(seconds: stats.exercisesTotalSeconds),
              ),
              progress: _ratio(
                stats.exercisesTotalSeconds,
                stats.exercisesGoalSeconds,
              ),
              color: TimeCategoryType.exercises.accentColor,
            ),
            _ProgressRow(
              icon: Icons.auto_stories_rounded,
              label: context.l10n.statPagesRead,
              value: context.l10n.metricPagesValue(stats.readingTotalPages),
              progress: _ratio(stats.readingTotalPages, stats.readingGoalPages),
              color: TimeCategoryType.reading.accentColor,
            ),
            _ProgressRow(
              icon: Icons.palette_rounded,
              label: TimeCategoryType.hobbies.localizedProfileLabel(context),
              value: formatDurationLong(
                Duration(seconds: stats.hobbiesTotalSeconds),
              ),
              progress: stats.hobbiesTotalSeconds > 0 ? 1 : 0,
              color: TimeCategoryType.hobbies.accentColor,
              isLast: true,
            ),
          ],
        ),
      ),
    ],
  );

  double _ratio(int current, int goal) =>
      goal <= 0 ? 0 : (current / goal).clamp(0, 1);
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
    child: Row(
      children: [
        _IconBadge(icon: icon, color: color, size: 28, iconSize: 15),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: context.textStyles.bodyTiny.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ),
              const Gap(6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EvolutionSection extends StatelessWidget {
  const _EvolutionSection({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.profileEvolutionTitle,
        style: context.textStyles.extraBold20,
      ),
      const Gap(12),
      Container(
        height: 156,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: _cardDecoration(context),
        child: CustomPaint(
          painter: _EvolutionChartPainter(
            values: values,
            color: context.colorTokens.primary,
            textColor: context.colorTokens.textHint,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ],
  );
}

class _EvolutionChartPainter extends CustomPainter {
  const _EvolutionChartPainter({
    required this.values,
    required this.color,
    required this.textColor,
  });

  final List<int> values;
  final Color color;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = textColor.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final int maxValue = values.fold<int>(
      1,
      (currentMax, value) => value > currentMax ? value : currentMax,
    );

    final double chartTop = 6;
    final double chartBottom = size.height - 24;
    final double chartHeight = chartBottom - chartTop;
    final double step = values.length <= 1
        ? 0
        : size.width / (values.length - 1);

    for (int i = 0; i < 3; i++) {
      final double y = chartTop + chartHeight * (i / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Path line = Path();
    final Path fill = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = i * step;
      final double normalizedValue = (values[i] / maxValue).clamp(0, 1);
      final double y = chartBottom - chartHeight * normalizedValue;
      if (i == 0) {
        line.moveTo(x, y);
        fill.moveTo(x, chartBottom);
        fill.lineTo(x, y);
      } else {
        line.lineTo(x, y);
        fill.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    fill.lineTo(size.width, chartBottom);
    fill.close();

    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(line, linePaint);
  }

  @override
  bool shouldRepaint(covariant _EvolutionChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.textColor != textColor;
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.stats, required this.onTapSeeAll});

  final ProfileStatsEntity stats;
  final VoidCallback onTapSeeAll;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        title: context.l10n.profileAchievementsTitle,
        action: context.l10n.profileSeeAll,
        onTapAction: onTapSeeAll,
      ),
      const Gap(12),
      Row(
        children: [
          Expanded(
            child: _AchievementBadge(
              icon: Icons.bolt_rounded,
              title: context.l10n.profileAchievementFirstFocus,
              color: context.colorTokens.primary,
              isUnlocked: stats.totalFocusSeconds > 0,
            ),
          ),
          const Gap(10),
          Expanded(
            child: _AchievementBadge(
              icon: Icons.school_rounded,
              title: context.l10n.profileAchievementStudyStarted,
              color: TimeCategoryType.studying.accentColor,
              isUnlocked: stats.studyingTotalSeconds > 0,
            ),
          ),
          const Gap(10),
          Expanded(
            child: _AchievementBadge(
              icon: Icons.auto_stories_rounded,
              title: context.l10n.profileAchievementReadingStarted,
              color: TimeCategoryType.reading.accentColor,
              isUnlocked: stats.readingTotalPages > 0,
            ),
          ),
          const Gap(10),
          Expanded(
            child: _AchievementBadge(
              icon: Icons.lock_rounded,
              title: context.l10n.profileAchievementLocked,
              color: context.colorTokens.textHint,
              isUnlocked: false,
            ),
          ),
        ],
      ),
    ],
  );
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.icon,
    required this.title,
    required this.color,
    required this.isUnlocked,
  });

  final IconData icon;
  final String title;
  final Color color;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = isUnlocked
        ? color
        : context.colorTokens.textHint;
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveColor.withValues(alpha: isUnlocked ? 0.16 : 0.08),
            border: Border.all(
              color: effectiveColor.withValues(alpha: isUnlocked ? 0.32 : 0.18),
            ),
          ),
          child: Icon(icon, color: effectiveColor, size: 26),
        ),
        const Gap(8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyTiny.copyWith(
            color: context.colorTokens.textBody,
          ),
        ),
      ],
    );
  }
}

class _ReadingSection extends StatelessWidget {
  const _ReadingSection({required this.stats});

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.profileTopReadingTitle,
        style: context.textStyles.extraBold20,
      ),
      const Gap(12),
      ProfileTopSubjectsList(subjects: stats.topReadingSubjects),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    this.onTapAction,
  });

  final String title;
  final String action;
  final VoidCallback? onTapAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: context.textStyles.extraBold20)),
      BounceTap(
        onTap: onTapAction ?? () {},
        pressedScale: onTapAction == null ? 1 : 0.94,
        child: Text(
          action,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    this.size = 34,
    this.iconSize = 18,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: isDarkMode ? 0.18 : 0.12),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: context.colorTokens.surface,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(
    color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
  ),
);

extension on TimeCategoryType {
  String localizedProfileLabel(BuildContext context) => switch (this) {
    TimeCategoryType.studying => context.l10n.statHoursStudied,
    TimeCategoryType.exercises => context.l10n.statHoursExercised,
    TimeCategoryType.reading => context.l10n.statPagesRead,
    TimeCategoryType.hobbies => context.l10n.categoryHobbies,
  };
}

extension on ProfilePeriod {
  String localizedLabel(BuildContext context) => switch (this) {
    ProfilePeriod.fiveDays => context.l10n.periodFiveDays,
    ProfilePeriod.week => context.l10n.periodWeek,
    ProfilePeriod.month => context.l10n.periodMonth,
  };
}
