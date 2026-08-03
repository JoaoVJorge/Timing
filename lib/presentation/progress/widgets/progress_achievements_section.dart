import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon_badge.dart";
import "package:help_out/shared/widgets/app_section_header.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// A milestone the user is working towards. Locked ones expose how far along
/// they are, which motivates far more than a padlock.
class _Milestone {
  const _Milestone({
    required this.icon,
    required this.title,
    required this.current,
    required this.target,
    required this.formatValue,
  });

  final IconData icon;
  final String title;
  final int current;
  final int target;
  final String Function(int value) formatValue;

  bool get isUnlocked => current >= target;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1);

  int get remaining => target - current;
}

/// Compact achievements block for the Progress page: what is next, then what is
/// already earned. The full catalogue lives on its own page.
class ProgressAchievementsSection extends StatelessWidget {
  const ProgressAchievementsSection({
    required this.hasGoalStarted,
    required this.hasValidFirstFocus,
    required this.activeDays,
    required this.sessions,
    required this.readingPages,
    required this.focusSeconds,
    required this.onTap,
    super.key,
  });

  final bool hasGoalStarted;
  final bool hasValidFirstFocus;
  final int activeDays;
  final int sessions;
  final int readingPages;
  final int focusSeconds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<_Milestone> milestones = _milestones(context);
    final List<_Milestone> unlocked = milestones
        .where((milestone) => milestone.isUnlocked)
        .toList();
    final _Milestone? next = _nextMilestone(milestones);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: context.l10n.profileAchievementsTitle,
          actionLabel: context.l10n.profileSeeAll,
          onTapAction: onTap,
        ),
        const Gap(AppSpacing.betweenRelated),
        if (next != null) ...[
          _NextMilestoneCard(milestone: next, onTap: onTap),
          const Gap(AppSpacing.betweenRelated),
        ],
        if (unlocked.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.titleToDescription,
            runSpacing: AppSpacing.titleToDescription,
            children: [
              for (final _Milestone milestone in unlocked.take(3))
                _UnlockedChip(title: milestone.title, icon: milestone.icon),
            ],
          ),
        ],
      ],
    );
  }

  /// Closest one to completion, so the user always sees an achievable target.
  _Milestone? _nextMilestone(List<_Milestone> milestones) {
    final List<_Milestone> locked = milestones
        .where((milestone) => !milestone.isUnlocked)
        .toList();
    if (locked.isEmpty) {
      return null;
    }
    locked.sort((a, b) => b.progress.compareTo(a.progress));
    return locked.first;
  }

  List<_Milestone> _milestones(BuildContext context) => [
    _Milestone(
      icon: Icons.bolt_rounded,
      title: context.l10n.profileAchievementFirstFocus,
      current: hasValidFirstFocus ? 1 : 0,
      target: 1,
      formatValue: (value) => "$value",
    ),
    _Milestone(
      icon: Icons.schedule_rounded,
      title: context.l10n.achievementFocusHourTitle,
      current: focusSeconds ~/ 60,
      target: 60,
      formatValue: context.l10n.unitMinutesShort,
    ),
    _Milestone(
      icon: Icons.track_changes_rounded,
      title: context.l10n.achievementSessionsTitle,
      current: sessions,
      target: 5,
      formatValue: context.l10n.unitSessions,
    ),
    _Milestone(
      icon: Icons.local_fire_department_rounded,
      title: context.l10n.achievementStreakTitle,
      current: activeDays,
      target: 7,
      formatValue: context.l10n.unitDays,
    ),
    _Milestone(
      icon: Icons.auto_stories_rounded,
      title: context.l10n.achievementReaderTitle,
      current: readingPages,
      target: 100,
      formatValue: (value) => "$value",
    ),
    _Milestone(
      icon: Icons.flag_rounded,
      title: context.l10n.achievementGoalStartedTitle,
      current: hasGoalStarted ? 1 : 0,
      target: 1,
      formatValue: (value) => "$value",
    ),
  ];
}

class _NextMilestoneCard extends StatelessWidget {
  const _NextMilestoneCard({required this.milestone, required this.onTap});

  final _Milestone milestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(
            icon: milestone.icon,
            color: context.colorTokens.primary,
            size: 40,
          ),
          const Gap(AppSpacing.betweenRelated),
          Text(
            context.l10n.progressAchievementsNextTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(fontSize: 12),
          ),
          const Gap(2),
          Text(
            milestone.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.cardTitle,
          ),
          const Gap(4),
          Text(
            context.l10n.achievementProgressValue(
              milestone.formatValue(milestone.current),
              milestone.formatValue(milestone.target),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Gap(AppSpacing.betweenRelated),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: milestone.progress,
              minHeight: 6,
              backgroundColor: context.colorTokens.primaryVeryLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colorTokens.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _UnlockedChip extends StatelessWidget {
  const _UnlockedChip({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.colorTokens.primary),
        const Gap(6),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
