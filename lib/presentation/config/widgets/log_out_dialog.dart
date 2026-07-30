import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class LogOutDialog extends StatelessWidget {
  const LogOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final Color danger = context.colorTokens.error;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: danger.withValues(alpha: 0.10),
                  ),
                  child: Icon(Icons.logout_rounded, color: danger, size: 40),
                ),
                const Gap(24),
                Text(
                  context.l10n.logOutDialogTitle,
                  textAlign: TextAlign.center,
                  style: context.textStyles.black32.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 28,
                    height: 1.08,
                  ),
                ),
                const Gap(18),
                Text(
                  context.l10n.logOutDialogContent,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyLarge.copyWith(
                    color: context.colorTokens.textBody.withValues(alpha: 0.78),
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(30),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: context.l10n.cancelButton,
                        foregroundColor: danger.withValues(alpha: 0.78),
                        borderColor: danger.withValues(alpha: 0.58),
                        onTap: () => appNavigator.back<bool>(result: false),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _DialogButton(
                        label: context.l10n.logOutConfirmButton,
                        foregroundColor: Colors.white,
                        backgroundColor: danger,
                        onTap: () => appNavigator.back<bool>(result: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.foregroundColor,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final Color foregroundColor;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: borderColor ?? Colors.transparent),
        ),
        textStyle: context.textStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}
