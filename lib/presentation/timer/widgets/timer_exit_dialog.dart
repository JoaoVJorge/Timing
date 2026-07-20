import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

Future<bool?> showTimerExitDialog({
  required BuildContext context,
  required Color accentColor,
  required String title,
  required String content,
  required String cancelLabel,
  required String confirmLabel,
}) => appNavigator.dialog<bool>(
  child: _TimerExitDialog(
    accentColor: accentColor,
    title: title,
    content: content,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
  ),
);

class _TimerExitDialog extends StatelessWidget {
  const _TimerExitDialog({
    required this.accentColor,
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final Color accentColor;
  final String title;
  final String content;
  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    backgroundColor: context.colorTokens.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
            ),
            child: Icon(Icons.logout_rounded, color: accentColor, size: 38),
          ),
          const Gap(24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogText,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const Gap(18),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogTextMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const Gap(12),
          Text(
            context.l10n.timerExitDialogContinueLater,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.textHint,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const Gap(24),
          Divider(color: context.colorTokens.divider),
          const Gap(22),
          Row(
            children: [
              Expanded(
                child: _TimerExitDialogButton(
                  label: cancelLabel,
                  textColor: context.colorTokens.dialogTextMuted,
                  borderColor: context.colorTokens.borderFocused,
                  onTap: () => appNavigator.back<bool>(result: false),
                ),
              ),
              const Gap(14),
              Expanded(
                child: _TimerExitDialogButton(
                  label: confirmLabel,
                  textColor: context.colorTokens.white,
                  backgroundColor: accentColor,
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

class _TimerExitDialogButton extends StatelessWidget {
  const _TimerExitDialogButton({
    required this.label,
    required this.textColor,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final Color textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorTokens.transparent,
        borderRadius: BorderRadius.circular(14),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
