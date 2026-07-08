import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Visual style for [AppButton]. Each variant reproduces a button that used to
/// live in its own widget, so appearance is unchanged across the app.
enum AppButtonVariant {
  /// White pill with a drop shadow that floats over page content. Used for the
  /// primary action pinned at the bottom of a screen or dialog.
  floating,

  /// White filled button sized for the gradient sign-in screens. Fades out when
  /// disabled so it reads as inactive against the gradient background.
  onGradient,
}

/// Full-width labelled action button. Use [AppIconButton] for the circular
/// icon-only variant.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onTap,
    this.variant = AppButtonVariant.floating,
    this.enabled = true,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final AppButtonVariant variant;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !isLoading;

    final Widget button = switch (variant) {
      AppButtonVariant.floating => _buildFloating(context),
      AppButtonVariant.onGradient => _buildOnGradient(
        context,
        isActive: isActive,
      ),
    };

    if (!isActive) {
      return button;
    }

    return BounceTap(pressedScale: 0.96, onTap: onTap, child: button);
  }

  Widget _buildFloating(BuildContext context) => Container(
    width: double.infinity,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
      ],
    ),
    child: isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colorTokens.primary,
            ),
          )
        : Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.extraBold20.copyWith(
              color: context.colorTokens.primary,
            ),
          ),
  );

  Widget _buildOnGradient(BuildContext context, {required bool isActive}) =>
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isActive ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: context.colorTokens.primary,
            // While loading we keep the solid white surface (it is an
            // in-progress action); when truly disabled we fade to a translucent
            // white so it reads as inactive against the gradient background.
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
}
