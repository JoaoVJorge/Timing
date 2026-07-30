import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/subject_icons.dart";

class ReadingSubjectTile extends StatelessWidget {
  const ReadingSubjectTile({
    required this.subject,
    required this.onTapPlay,
    super.key,
  });

  final SubjectEntity subject;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);
    final bool hasGoal = subject.goalPages > 0;
    final double progress = hasGoal
        ? (subject.currentPages / subject.goalPages).clamp(0, 1)
        : 0;
    final int percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ReadingCover(subject: subject, color: color),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.extraBold24.copyWith(
                          fontSize: 20,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const Gap(8),
                    _ReadingPlayButton(onTap: onTapPlay),
                  ],
                ),
                const Gap(12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ReadingMetric(
                      icon: Icons.schedule_rounded,
                      label: _durationLabel(context),
                    ),
                    _ReadingMetricDivider(color: context.colorTokens.divider),
                    _ReadingMetric(
                      icon: Icons.article_outlined,
                      label: _pagesLabel(context, hasGoal: hasGoal),
                    ),
                    _ReadingMetricDivider(color: context.colorTokens.divider),
                    _ReadingMetric(
                      icon: Icons.track_changes_rounded,
                      label: "$percent%",
                    ),
                  ],
                ),
                const Gap(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.16),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(BuildContext context) {
    final Duration duration = Duration(seconds: subject.totalSeconds);
    if (duration.inHours == 0) {
      return context.l10n.restMinutesChip(duration.inMinutes);
    }
    return formatDurationLong(duration);
  }

  String _pagesLabel(BuildContext context, {required bool hasGoal}) {
    final String suffix = switch (context.languageCode) {
      "en" => "pgs",
      "es" => "págs",
      "fr" => "p.",
      "de" => "S.",
      "ar" => "صفحات",
      _ => "págs",
    };

    if (!hasGoal) {
      return "${subject.currentPages} $suffix";
    }
    return "${subject.currentPages}/${subject.goalPages} $suffix";
  }
}

class _ReadingCover extends StatelessWidget {
  const _ReadingCover({required this.subject, required this.color});

  final SubjectEntity subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String iconName = subject.iconName.isEmpty
        ? "book"
        : subject.iconName;
    final IconData? icon = SubjectIcons.byName(iconName);

    return Container(
      width: 58,
      height: 78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, context.colorTokens.white, 0.04) ?? color,
            Color.lerp(color, context.colorTokens.black, 0.08) ?? color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: icon == null
            ? AppIcon(iconName, size: 28, color: context.colorTokens.white)
            : Icon(icon, size: 28, color: context.colorTokens.white),
      ),
    );
  }
}

class _ReadingPlayButton extends StatelessWidget {
  const _ReadingPlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: context.colorTokens.primaryGradient,
      ),
      child: Center(
        child: AppIcon("play", size: 20, color: context.colorTokens.white),
      ),
    ),
  );
}

class _ReadingMetric extends StatelessWidget {
  const _ReadingMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: context.colorTokens.primary),
      const Gap(4),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          color: context.colorTokens.textBody,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _ReadingMetricDivider extends StatelessWidget {
  const _ReadingMetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1.2, height: 20, color: color);
}
