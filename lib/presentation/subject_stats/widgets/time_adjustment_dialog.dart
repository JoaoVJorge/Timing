import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/functions/format_duration.dart";

/// Asks how much time to add to an activity or take back off it. Answers in
/// seconds, never more than [maxSeconds], or null when the user gives up.
typedef TimeAmountPicker =
    Future<int?> Function({required bool isRemoving, required int maxSeconds});

Future<int?> showTimeAdjustmentDialog({
  required bool isRemoving,
  required int maxSeconds,
}) => appNavigator.modalBottomSheet<int>(
  isScrollControlled: true,
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
  // Round up only for the input range. Confirmation uses the exact remaining
  // seconds so the final partial minute can still be removed.
  late final int _maxMinutes = math.max(0, (widget.maxSeconds / 60).ceil());
  late final TextEditingController _amountController = TextEditingController(
    text: math.min(30, _maxMinutes).toString(),
  );

  int? get _minutes => int.tryParse(_amountController.text);
  bool get _isValid =>
      _minutes != null && _minutes! > 0 && _minutes! <= _maxMinutes;
  int get _seconds => math.min((_minutes ?? 0) * 60, widget.maxSeconds);

  void _setMinutes(int minutes) {
    setState(() {
      final String text = minutes.toString();
      _amountController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  void _stepBy(int change) {
    if (_maxMinutes < 1) return;
    _setMinutes(((_minutes ?? 0) + change).clamp(1, _maxMinutes));
  }

  void _confirm() {
    if (_isValid) Navigator.of(context).pop(_seconds);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colorTokens.primary;
    final String? fontFamily = Theme.of(
      context,
    ).textTheme.bodyMedium?.fontFamily;
    final List<int> presets = [
      for (final minutes in [15, 30, 60])
        if (minutes * 60 <= widget.maxSeconds) minutes,
    ];
    final String actionLabel = widget.isRemoving
        ? context.l10n.removeTimeConfirmLabel
        : context.l10n.addButton;

    return Material(
      color: context.colorTokens.dialogSurface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colorTokens.textHint.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isRemoving
                            ? context.l10n.removeTimeButtonLabel
                            : context.l10n.addTimeButtonLabel,
                        style: context.textStyles.dialogTitle.copyWith(
                          fontFamily: fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.colorTokens.textBody,
                        ),
                      ),
                    ),
                    const Gap(8),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: context.colorTokens.textHint,
                        backgroundColor: context.colorTokens.surfaceInnerLayer,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  widget.isRemoving
                      ? context.l10n.removeTimeDialogMessage
                      : context.l10n.addTimeDialogMessage,
                  style: context.textStyles.caption.copyWith(
                    fontFamily: fontFamily,
                  ),
                ),
                const Gap(24),
                Row(
                  children: [
                    _StepButton(
                      key: const ValueKey<String>("time-adjustment-minus"),
                      icon: Icons.remove_rounded,
                      label: "−1 ${context.l10n.timeUnitMinutesSuffix}",
                      color: accent,
                      onTap: _maxMinutes > 0 && (_minutes ?? 0) > 1
                          ? () => _stepBy(-1)
                          : null,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        children: [
                          Semantics(
                            label: context.l10n.estimatedHoursGoalHint,
                            child: TextField(
                              key: const ValueKey<String>(
                                "time-adjustment-value",
                              ),
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              style: context.textStyles.metricValue.copyWith(
                                fontFamily: fontFamily,
                                color: context.colorTokens.textBody,
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                hintText: "0",
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onTap: () =>
                                  _amountController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _amountController.text.length,
                                  ),
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _confirm(),
                            ),
                          ),
                          Text(
                            context.l10n.estimatedHoursGoalHint,
                            textAlign: TextAlign.center,
                            style: context.textStyles.caption.copyWith(
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    _StepButton(
                      key: const ValueKey<String>("time-adjustment-plus"),
                      icon: Icons.add_rounded,
                      label: "+1 ${context.l10n.timeUnitMinutesSuffix}",
                      color: accent,
                      onTap: (_minutes ?? 0) < _maxMinutes
                          ? () => _stepBy(1)
                          : null,
                    ),
                  ],
                ),
                const Gap(24),
                if (presets.isNotEmpty) ...[
                  Row(
                    children: [
                      for (int index = 0; index < presets.length; index++) ...[
                        if (index > 0) const Gap(8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _setMinutes(presets[index]),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colorTokens.textHint,
                              minimumSize: const Size(0, 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              side: BorderSide(
                                color: context.colorTokens.borderUnfocused,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: context.textStyles.caption.copyWith(
                                fontFamily: fontFamily,
                              ),
                            ),
                            child: Text(_durationLabel(presets[index] * 60)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(18),
                ],
                FilledButton(
                  key: const ValueKey<String>("time-adjustment-confirm"),
                  onPressed: _isValid ? _confirm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: context.colorTokens.white,
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: context.textStyles.bodyMedium.copyWith(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(
                    _isValid
                        ? "$actionLabel ${_durationLabel(_seconds)}"
                        : actionLabel,
                    key: const ValueKey<String>("time-adjustment-preview"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _durationLabel(int seconds) {
    final duration = Duration(seconds: seconds);
    final remainder = seconds % 60;
    if (seconds < 60) return formatDurationTotalSeconds(duration);
    return "${formatDurationLong(duration)}${remainder == 0 ? '' : ' ${remainder}s'}";
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: label,
    onPressed: onTap,
    icon: Icon(icon, size: 26),
    style: IconButton.styleFrom(
      minimumSize: const Size(48, 48),
      foregroundColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
    ),
  );
}
