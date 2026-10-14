import "dart:async";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

import "package:timing/theme/app_spacing.dart";

Future<bool> showAppConfirmationDialog({
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required IconData icon,
  bool isDestructive = false,
}) async {
  final bool? confirmed = await appNavigator.dialog<bool>(
    child: _AppConfirmationDialog(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      icon: icon,
      isDestructive: isDestructive,
    ),
  );
  return confirmed ?? false;
}

class _AppConfirmationDialog extends StatelessWidget {
  const _AppConfirmationDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.icon,
    required this.isDestructive,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color actionColor = isDestructive
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
              child: Icon(icon, color: context.colorTokens.white, size: 28),
            ),
            const Gap(14),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textStyles.dialogTitle,
            ),
            const Gap(10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.dialogBody,
            ),
            const Gap(22),
            Row(
              children: [
                Expanded(
                  child: _ConfirmationButton(
                    label: cancelLabel,
                    foreground: context.colorTokens.primary,
                    borderColor: context.colorTokens.primary,
                    onTap: () => appNavigator.back<bool>(result: false),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _ConfirmationButton(
                    label: confirmLabel,
                    foreground: context.colorTokens.white,
                    gradient: isDestructive
                        ? LinearGradient(
                            colors: [
                              actionColor,
                              Color.lerp(actionColor, Colors.redAccent, 0.35) ??
                                  actionColor,
                            ],
                          )
                        : context.colorTokens.primaryGradient,
                    onTap: () => appNavigator.back<bool>(result: true),
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

Future<bool> showCountdownConfirmationDialog({
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required String Function(int seconds) waitLabelBuilder,
  required IconData icon,
  int countdownSeconds = 5,
}) async {
  final bool? confirmed = await appNavigator.dialog<bool>(
    child: _CountdownConfirmationDialog(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      waitLabelBuilder: waitLabelBuilder,
      icon: icon,
      countdownSeconds: countdownSeconds,
    ),
  );
  return confirmed ?? false;
}

class _CountdownConfirmationDialog extends StatefulWidget {
  const _CountdownConfirmationDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.waitLabelBuilder,
    required this.icon,
    required this.countdownSeconds,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final String Function(int seconds) waitLabelBuilder;
  final IconData icon;
  final int countdownSeconds;

  @override
  State<_CountdownConfirmationDialog> createState() =>
      _CountdownConfirmationDialogState();
}

class _CountdownConfirmationDialogState
    extends State<_CountdownConfirmationDialog> {
  late int _remainingSeconds = widget.countdownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color actionColor = context.colorTokens.error;
    final bool isReady = _remainingSeconds <= 0;

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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: actionColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: context.colorTokens.white,
                size: 28,
              ),
            ),
            const Gap(16),
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textStyles.dialogTitle,
            ),
            const Gap(12),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: context.textStyles.dialogBody,
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: _ConfirmationButton(
                    label: widget.cancelLabel,
                    foreground: context.colorTokens.primary,
                    borderColor: context.colorTokens.primary,
                    onTap: () => appNavigator.back<bool>(result: false),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _ConfirmationButton(
                    label: isReady
                        ? widget.confirmLabel
                        : widget.waitLabelBuilder(_remainingSeconds),
                    foreground: isReady
                        ? context.colorTokens.white
                        : context.colorTokens.textHint,
                    fill: isReady
                        ? null
                        : context.colorTokens.surfaceInnerLayer,
                    gradient: isReady
                        ? LinearGradient(
                            colors: [
                              actionColor,
                              Color.lerp(actionColor, Colors.redAccent, 0.35) ??
                                  actionColor,
                            ],
                          )
                        : null,
                    onTap: isReady
                        ? () => appNavigator.back<bool>(result: true)
                        : null,
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

class _ConfirmationButton extends StatelessWidget {
  const _ConfirmationButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.gradient,
    this.fill,
  });

  final String label;
  final Color foreground;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Gradient? gradient;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final Widget button = Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
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
    );
    final VoidCallback? tapHandler = onTap;
    if (tapHandler == null) {
      return button;
    }
    return BounceTap(onTap: tapHandler, pressedScale: 0.97, child: button);
  }
}
