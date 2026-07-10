import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_visual_state.dart";

class TimerActionButtons extends StatelessWidget {
  const TimerActionButtons({
    required this.state,
    required this.onPrimaryTap,
    required this.onEndTap,
    required this.onSkipRestTap,
    super.key,
  });

  final TimerVisualState state;
  final VoidCallback onPrimaryTap;
  final VoidCallback onEndTap;
  final VoidCallback onSkipRestTap;

  @override
  Widget build(BuildContext context) {
    final bool isResting = state == TimerVisualState.resting;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isResting ? onPrimaryTap : onPrimaryTap,
            icon: Icon(_primaryIcon),
            label: Text(_primaryLabel(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorTokens.white,
              foregroundColor: context.colorTokens.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const Gap(12),
        Row(
          children: [
            if (isResting) ...[
              Expanded(
                child: _SecondaryButton(
                  label: context.l10n.timerSkipRestButton,
                  icon: Icons.fast_forward_rounded,
                  onTap: onSkipRestTap,
                ),
              ),
              const Gap(12),
            ],
            Expanded(
              child: _SecondaryButton(
                label: context.l10n.timerEndSessionButton,
                icon: Icons.stop_rounded,
                onTap: onEndTap,
              ),
            ),
          ],
        ),
        const Gap(8),
        Text(
          context.l10n.timerSaveReassurance,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.white.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }

  IconData get _primaryIcon => switch (state) {
    TimerVisualState.resting => Icons.play_arrow_rounded,
    TimerVisualState.paused => Icons.play_arrow_rounded,
    TimerVisualState.finished => Icons.refresh_rounded,
    TimerVisualState.focusing => Icons.pause_rounded,
  };

  String _primaryLabel(BuildContext context) => switch (state) {
    TimerVisualState.resting => context.l10n.timerContinueFocusButton,
    TimerVisualState.paused => context.l10n.timerContinueButton,
    TimerVisualState.finished => context.l10n.timerStartAnotherSessionButton,
    TimerVisualState.focusing => context.l10n.timerPauseButton,
  };
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colorTokens.white,
        side: BorderSide(
          color: context.colorTokens.white.withValues(alpha: 0.32),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
