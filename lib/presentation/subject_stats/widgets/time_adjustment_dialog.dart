import "dart:math" as math;

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_spacing.dart";

/// Asks how much time to add to an activity or take back off it. Answers in
/// seconds, never more than [maxSeconds], or null when the user gives up.
typedef TimeAmountPicker =
    Future<int?> Function({required bool isRemoving, required int maxSeconds});

Future<int?> showTimeAdjustmentDialog({
  required bool isRemoving,
  required int maxSeconds,
}) => appNavigator.dialog<int>(
  child: TimeAdjustmentDialog(isRemoving: isRemoving, maxSeconds: maxSeconds),
);

class TimeAdjustmentDialog extends StatefulWidget {
  const TimeAdjustmentDialog({
    required this.isRemoving,
    required this.maxSeconds,
    super.key,
  });

  final bool isRemoving;
  final int maxSeconds;

  @override
  State<TimeAdjustmentDialog> createState() => _TimeAdjustmentDialogState();
}

class _TimeAdjustmentDialogState extends State<TimeAdjustmentDialog> {
  static const int _step = 5;
  static const List<int> _presets = [15, 30, 60, 120];

  /// What is left of a minute still counts as one to choose from, so an
  /// activity with under a minute on it can be emptied.
  late final int _maxMinutes = math.max(1, (widget.maxSeconds / 60).ceil());
  late final int _minMinutes = math.min(_step, _maxMinutes);
  late int _minutes = math.min(30, _maxMinutes);

  /// Moves to the next multiple of [_step], so a value that was cut short by
  /// the limit falls back onto the grid.
  void _stepBy({required bool up}) {
    final int next = up
        ? (_minutes ~/ _step + 1) * _step
        : ((_minutes - 1) ~/ _step) * _step;
    setState(() => _minutes = next.clamp(_minMinutes, _maxMinutes));
  }

  void _confirm() => appNavigator.back<int>(
    result: math.min(_minutes * 60, widget.maxSeconds),
  );

  @override
  Widget build(BuildContext context) {
    final Color actionColor = widget.isRemoving
        ? context.colorTokens.error
        : context.colorTokens.primary;

    return Dialog(
      elevation: 0,
      backgroundColor: context.colorTokens.transparent,
      insetPadding: AppSpacing.confirmationDialogInset,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        padding: AppSpacing.confirmationDialog,
        decoration: BoxDecoration(
          color: context.colorTokens.dialogSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: actionColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isRemoving
                    ? Icons.timer_off_rounded
                    : Icons.more_time_rounded,
                color: context.colorTokens.white,
                size: 28,
              ),
            ),
            const Gap(14),
            Text(
              widget.isRemoving
                  ? context.l10n.removeTimeButtonLabel
                  : context.l10n.addTimeButtonLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textStyles.dialogTitle,
            ),
            const Gap(10),
            Text(
              widget.isRemoving
                  ? context.l10n.removeTimeDialogMessage
                  : context.l10n.addTimeDialogMessage,
              textAlign: TextAlign.center,
              style: context.textStyles.dialogBody,
            ),
            const Gap(18),
            Row(
              children: [
                _StepButton(
                  key: const ValueKey<String>("time-adjustment-minus"),
                  icon: Icons.remove_rounded,
                  color: actionColor,
                  onTap: _minutes > _minMinutes
                      ? () => _stepBy(up: false)
                      : null,
                ),
                Expanded(
                  child: Text(
                    formatDurationLong(Duration(minutes: _minutes)),
                    key: const ValueKey<String>("time-adjustment-value"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textStyles.metricValue.copyWith(
                      color: actionColor,
                    ),
                  ),
                ),
                _StepButton(
                  key: const ValueKey<String>("time-adjustment-plus"),
                  icon: Icons.add_rounded,
                  color: actionColor,
                  onTap: _minutes < _maxMinutes
                      ? () => _stepBy(up: true)
                      : null,
                ),
              ],
            ),
            const Gap(14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final int preset in _presets)
                  if (preset <= _maxMinutes)
                    _PresetChip(
                      label: formatDurationLong(Duration(minutes: preset)),
                      isSelected: preset == _minutes,
                      color: actionColor,
                      onTap: () => setState(() => _minutes = preset),
                    ),
              ],
            ),
            const Gap(22),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.l10n.cancelButton,
                    foreground: context.colorTokens.primary,
                    borderColor: context.colorTokens.primary,
                    onTap: () => appNavigator.back<int>(),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _DialogButton(
                    key: const ValueKey<String>("time-adjustment-confirm"),
                    label: widget.isRemoving
                        ? context.l10n.removeTimeConfirmLabel
                        : context.l10n.addButton,
                    foreground: context.colorTokens.white,
                    gradient: widget.isRemoving
                        ? LinearGradient(
                            colors: [
                              actionColor,
                              Color.lerp(actionColor, Colors.redAccent, 0.35) ??
                                  actionColor,
                            ],
                          )
                        : context.colorTokens.primaryGradient,
                    onTap: _confirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;

  /// Null at the end of the range, which leaves the button dimmed.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget button = Opacity(
      opacity: onTap == null ? 0.35 : 1,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
    final VoidCallback? tapHandler = onTap;
    if (tapHandler == null) {
      return button;
    }
    return BounceTap(onTap: tapHandler, pressedScale: 0.92, child: button);
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(
          color: isSelected ? context.colorTokens.white : color,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.gradient,
    super.key,
  });

  final String label;
  final Color foreground;
  final VoidCallback onTap;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.dialogButtonLabel.copyWith(color: foreground),
      ),
    ),
  );
}
