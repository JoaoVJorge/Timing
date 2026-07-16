import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/login/login_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/auth_onboarding_widgets.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find();

    return AuthOnboardingScaffold(
      title: context.l10n.loginHeadline,
      subtitle: context.l10n.loginSubtitle,
      topVisual: const AuthHeroPlaceholder(
        icon: Icons.menu_book_rounded,
        large: true,
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SignInOption(
            icon: const AppIcon("google", size: 26),
            label: context.l10n.continueWithGoogleButton,
            onTap: controller.onTapGoogleSignIn,
          ),
          const Gap(9),
          _SignInOption(
            icon: const Icon(Icons.apple, size: 30, color: Colors.black),
            label: context.l10n.continueWithAppleButton,
            onTap: controller.onTapAppleSignIn,
          ),
          const Gap(9),
          _SignInOption(
            icon: const Icon(
              Icons.phone_iphone_rounded,
              size: 25,
              color: AuthOnboardingColors.yellowDark,
            ),
            label: context.l10n.continueWithPhoneButton,
            onTap: controller.onTapPhoneSignIn,
            highlighted: true,
          ),
        ],
      ),
      children: const [],
    );
  }
}

class _SignInOption extends StatelessWidget {
  const _SignInOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: AuthOnboardingDecorations.card,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlighted
                  ? AuthOnboardingColors.yellow.withValues(alpha: 0.14)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AuthOnboardingColors.navy.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: AuthOnboardingColors.navy.withValues(alpha: 0.08),
                  blurRadius: 9,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: icon,
          ),
          const Gap(14),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AuthOnboardingTextStyles.fieldValue,
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AuthOnboardingColors.navy,
            size: 28,
          ),
        ],
      ),
    ),
  );
}
