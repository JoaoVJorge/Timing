import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// White filled action button used across the phone sign-in flow. Shows a
/// loading spinner while [isLoading] and is greyed out when [enabled] is false.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !isLoading;

    final Widget button = SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isActive ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: context.colorTokens.primary,
          // While loading we keep the solid white surface (it is an in-progress
          // action); when truly disabled we fade to a translucent white so it
          // reads as inactive against the gradient background.
          disabledBackgroundColor: isLoading
              ? Colors.white
              : Colors.white.withValues(alpha: 0.22),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorTokens.primary,
                ),
              )
            : Text(
                label,
                style: context.textStyles.bodyLarge.copyWith(
                  color: isActive
                      ? context.colorTokens.textBody
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
      ),
    );

    if (!isActive) {
      return button;
    }

    return BounceTap(pressedScale: 0.96, onTap: onTap, child: button);
  }
}
