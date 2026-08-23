import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

Future<bool> showAppConfirmationDialog({
  required String title,
  required String message,
  required String confirmLabel,
  required IconData icon,
  bool isDestructive = false,
}) async {
  final bool? confirmed = await appNavigator.dialog<bool>(
    child: _AppConfirmationDialog(
      title: title,
      message: message,
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
    required this.confirmLabel,
    required this.icon,
    required this.isDestructive,
  });

  final String title;
  final String message;
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 34),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
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
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 21,
                height: 1.12,
              ),
            ),
            const Gap(10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogTextMuted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
            const Gap(22),
            Row(
              children: [
                Expanded(
                  child: _ConfirmationButton(
                    label: "Voltar",
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

class _ConfirmationButton extends StatelessWidget {
  const _ConfirmationButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.gradient,
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
        style: context.textStyles.bodyLarge.copyWith(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
