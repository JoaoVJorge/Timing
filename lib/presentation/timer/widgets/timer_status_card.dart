import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_visual_state.dart";
import "package:help_out/shared/functions/format_duration.dart";

class TimerStatusCard extends StatelessWidget {
  const TimerStatusCard({
    required this.subjectName,
    required this.state,
    required this.sessionSeconds,
    required this.totalSeconds,
    required this.breakCountdownSeconds,
    required this.restCountdownSeconds,
    required this.restIntervalSeconds,
    required this.focusProgress,
    super.key,
  });

  final String subjectName;
  final TimerVisualState state;
  final int sessionSeconds;
  final int totalSeconds;
  final int breakCountdownSeconds;
  final int restCountdownSeconds;
  final int restIntervalSeconds;
  final double focusProgress;

  @override
  Widget build(BuildContext context) {
    final bool isResting = state == TimerVisualState.resting;
    final bool isPaused = state == TimerVisualState.paused;
    final Color accent = isResting
        ? context.colorTokens.success
        : isPaused
        ? Colors.amber
        : context.colorTokens.primary;
    final int mainSeconds = isResting ? restCountdownSeconds : sessionSeconds;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Text(
            _eyebrow(context),
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(8),
          Text(
            _description(context),
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const Gap(24),
          SizedBox(
            width: 214,
            height: 214,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: isResting
                        ? 1 - (restCountdownSeconds / restIntervalSeconds)
                        : focusProgress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatDurationClock(Duration(seconds: mainSeconds)),
                      style: context.textStyles.black32.copyWith(
                        fontSize: 52,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      isResting
                          ? context.l10n.timerRestTimeLabel
                          : context.l10n.timerCurrentFocusLabel,
                      style: context.textStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),
          Text(
            isResting
                ? context.l10n.timerRestingLabel(
                    formatDurationClock(
                      Duration(seconds: restCountdownSeconds),
                    ),
                  )
                : context.l10n.timerNextBreakLabel(
                    formatDurationClock(
                      Duration(seconds: breakCountdownSeconds),
                    ),
                  ),
            style: context.textStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: context.l10n.timerSessionLabel,
                  value: formatDurationLong(Duration(seconds: sessionSeconds)),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _MetricTile(
                  label: context.l10n.timerTotalInSubject(subjectName),
                  value: formatDurationLong(Duration(seconds: totalSeconds)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _eyebrow(BuildContext context) => switch (state) {
    TimerVisualState.resting => context.l10n.timerStateRestingTitle,
    TimerVisualState.paused => context.l10n.timerStatePausedTitle,
    TimerVisualState.finished => context.l10n.timerSessionSavedTitle,
    TimerVisualState.focusing => context.l10n.timerStateFocusingTitle,
  };

  String _description(BuildContext context) => switch (state) {
    TimerVisualState.resting => context.l10n.timerStateRestingDescription,
    TimerVisualState.paused => context.l10n.timerStatePausedDescription,
    TimerVisualState.finished => context.l10n.timerSessionSavedDescription,
    TimerVisualState.focusing => context.l10n.timerStateFocusingDescription,
  };
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const Gap(4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
