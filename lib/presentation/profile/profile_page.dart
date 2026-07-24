import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 18, bottom: 16),
        child: Obx(() {
          final ProfileStatsEntity stats = controller.stats.value;
          final ProfilePeriod selectedPeriod = controller.selectedPeriod.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _JourneyHeader(),
              const Gap(6),
              _TopAchievementsStrip(
                hasAnyUnlockedAchievement: controller.hasAnyUnlockedAchievement,
                hasGoalStarted: controller.hasGoalStarted,
                hasValidFirstFocus: controller.hasValidFirstFocus,
                onTap: controller.onTapAchievements,
              ),
              const Gap(16),
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
              _SocialSection(onTapFriends: controller.onTapFriends),
              const Gap(20),
              _ReadingSection(stats: stats),
            ],
          );
        }),
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.profileTitle,
        style: context.textStyles.black32.copyWith(fontSize: 34),
      ),
      const Gap(4),
      Text(
        context.l10n.profileSubtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyLarge.copyWith(
          color: context.colorTokens.textHint,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _TopAchievementsStrip extends StatelessWidget {
  const _TopAchievementsStrip({
    required this.hasAnyUnlockedAchievement,
    required this.hasGoalStarted,
    required this.hasValidFirstFocus,
    required this.onTap,
  });

  final bool hasAnyUnlockedAchievement;
  final bool hasGoalStarted;
  final bool hasValidFirstFocus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(6),
          Expanded(
            flex: 12,
            child: _TopAchievementChip(
              icon: Icons.emoji_events_rounded,
              title: context.l10n.profileAchievementFirstUnlocked,
              color: context.colorTokens.primary,
              isUnlocked: hasAnyUnlockedAchievement,
              isFeatured: true,
              onTap: onTap,
            ),
          ),
          const Gap(10),
          Expanded(
            flex: 10,
            child: Column(
              children: [
                _TopAchievementChip(
                  icon: Icons.track_changes_rounded,
                  title: context.l10n.profileAchievementGoalStarted,
                  color: context.colorTokens.primary,
                  isUnlocked: hasGoalStarted,
                  onTap: onTap,
                ),
                const Gap(8),
                _TopAchievementChip(
                  icon: Icons.eco_rounded,
                  title: context.l10n.profileAchievementFirstFocus,
                  color: context.colorTokens.primary,
                  isUnlocked: hasValidFirstFocus,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
      if (!hasAnyUnlockedAchievement) ...[
        const Gap(6),
        Text(
          context.l10n.profileAchievementsStartHint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ],
  );
}

class _TopAchievementChip extends StatelessWidget {
  const _TopAchievementChip({
    required this.icon,
    required this.title,
    required this.color,
    required this.isUnlocked,
    required this.onTap,
    this.isFeatured = false,
  });

  final IconData icon;
  final String title;
  final Color color;
  final bool isUnlocked;
  final VoidCallback onTap;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = isUnlocked
        ? color
        : context.colorTokens.textHint;
    final double height = isFeatured ? 100 : 46;
    final double iconSize = isFeatured ? 56 : 32;
    final double innerIconSize = isFeatured ? 32 : 18;
    final double textSize = isFeatured ? 20 : 12.5;
    final double radius = isFeatured ? 16 : 14;

    return BounceTap(
      onTap: onTap,
      pressedScale: 0.97,
      child: Stack(
        children: [
          Container(
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: isFeatured ? 12 : 12,
              vertical: isFeatured ? 12 : 6,
            ),
            decoration: BoxDecoration(
              color: context.colorTokens.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isUnlocked && isFeatured
                    ? color.withValues(alpha: 0.30)
                    : context.colorTokens.borderUnfocused.withValues(
                        alpha: 0.60,
                      ),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colorTokens.surfaceShadow,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveColor.withValues(
                      alpha: isUnlocked ? 0.14 : 0.10,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? icon : Icons.lock_rounded,
                    color: effectiveColor,
                    size: innerIconSize,
                  ),
                ),
                Gap(isFeatured ? 12 : 8),
                Expanded(
                  child: isFeatured
                      ? _FeaturedAchievementTitle(
                          title: title,
                          color: isUnlocked
                              ? color
                              : context.colorTokens.textBody.withValues(
                                  alpha: 0.72,
                                ),
                        )
                      : Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodyMedium.copyWith(
                            color: isUnlocked
                                ? color
                                : context.colorTokens.textBody.withValues(
                                    alpha: 0.72,
                                  ),
                            fontSize: textSize,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Positioned(
              right: 10,
              bottom: 8,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: isFeatured ? 16 : 12,
                color: color.withValues(alpha: 0.35),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedAchievementTitle extends StatelessWidget {
  const _FeaturedAchievementTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = title.split(" ");
    final String firstLine = parts.isEmpty ? title : parts.first;
    final String secondLine = parts.length <= 1
        ? ""
        : parts.sublist(1).join(" ");

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.black20.copyWith(
            color: color,
            fontSize: 24,
            height: 0.96,
          ),
          textAlign: TextAlign.center,
        ),
        if (secondLine.isNotEmpty)
          Text(
            secondLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyMedium.copyWith(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
      ],
    );
  }
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
                  color: context.colorTokens.white,
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
                  color: context.colorTokens.white,
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
        style: context.textStyles.bodyMedium.copyWith(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.textHint,
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
    final int rawMaxValue = values.fold<int>(
      60,
      (currentMax, value) => value > currentMax ? value : currentMax,
    );
    final int interval = rawMaxValue <= 3600 ? 1800 : 3600;
    final int maxValue = ((rawMaxValue + interval - 1) ~/ interval) * interval;

    final double chartTop = 6;
    final double chartBottom = size.height - 24;
    final double chartHeight = chartBottom - chartTop;
    const double labelWidth = 42;
    final double chartLeft = labelWidth;
    final double chartWidth = size.width - chartLeft;
    final double step = values.length <= 1
        ? 0
        : chartWidth / (values.length - 1);

    for (int i = 0; i < 3; i++) {
      final double y = chartTop + chartHeight * (i / 2);
      canvas.drawLine(Offset(chartLeft, y), Offset(size.width, y), gridPaint);
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: _formatChartLabel((maxValue * (2 - i) / 2).round()),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth - 6);
      labelPainter.paint(canvas, Offset(0, y - labelPainter.height / 2));
    }

    final Path line = Path();
    final Path fill = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = chartLeft + (i * step);
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

  String _formatChartLabel(int seconds) {
    if (seconds >= 3600) {
      final int hours = seconds ~/ 3600;
      final int minutes = (seconds % 3600) ~/ 60;
      return minutes == 0 ? "${hours}h" : "${hours}h${minutes}m";
    }

    final int minutes = (seconds / 60).round();
    return minutes <= 0 ? "0min" : "${minutes}min";
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.onTapFriends});

  final VoidCallback onTapFriends;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(_socialTitle(context), style: context.textStyles.extraBold20),
      const Gap(12),
      Container(
        decoration: _cardDecoration(
          context,
        ).copyWith(borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            _SocialTile(
              icon: Icons.group_rounded,
              title: _friendsTitle(context),
              subtitle: _friendsSubtitle(context),
              detail: _friendsDetail(context),
              onTap: onTapFriends,
            ),
            Divider(
              height: 1,
              indent: 76,
              endIndent: 18,
              color: context.colorTokens.divider,
            ),
            _SocialTile(
              icon: Icons.qr_code_rounded,
              title: _inviteCodeTitle(context),
              subtitle: _inviteCodeSubtitle(context),
              onTap: () async {
                final String message = _inviteCodeCopied(context);
                await Clipboard.setData(const ClipboardData(text: "JOAO-2841"));
                appNavigator.showSuccessSnackBar(message);
              },
            ),
          ],
        ),
      ),
    ],
  );

  String _socialTitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Social",
    "pt" => "Social",
    _ => "Social",
  };

  String _friendsTitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Amigos",
    "pt" => "Amigos",
    _ => "Friends",
  };

  String _friendsSubtitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Gestiona amigos y solicitudes",
        "pt" => "Gerencie amigos e solicitações",
        _ => "Manage friends and requests",
      };

  String _friendsDetail(BuildContext context) => switch (context.languageCode) {
    "es" => "12 amigos • 2 pendientes",
    "pt" => "12 amigos • 2 pendentes",
    _ => "12 friends • 2 pending",
  };

  String _inviteCodeTitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Código de invitación",
        "pt" => "Código de convite",
        _ => "Invite code",
      };

  String _inviteCodeSubtitle(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Comparte para agregar amigos",
        "pt" => "Compartilhe para adicionar amigos",
        _ => "Share to add friends",
      };

  String _inviteCodeCopied(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Código copiado",
        "pt" => "Código copiado",
        _ => "Code copied",
      };
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.detail,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _IconBadge(
            icon: icon,
            color: context.colorTokens.primary,
            size: 46,
            iconSize: 23,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail != null) ...[
                  const Gap(2),
                  Text(
                    detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
          Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
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
