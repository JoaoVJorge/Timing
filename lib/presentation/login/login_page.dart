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
      brandGradient: AuthOnboardingColors.blueGradient,
      topVisual: const AuthHeroPlaceholder(
        icon: Icons.menu_book_rounded,
        large: true,
        accent: AuthOnboardingColors.blue,
        accentDark: AuthOnboardingColors.blueDark,
        accentLight: AuthOnboardingColors.blueLight,
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => _SignInOption(
              icon: const AppIcon("google", size: 26),
              label: context.l10n.continueWithGoogleButton,
              onTap: controller.onTapGoogleSignIn,
              isLoading: controller.isGoogleSubmitting.value,
            ),
          ),
          const Gap(9),
          _SignInOption(
            icon: const Icon(Icons.apple, size: 30, color: Colors.black),
            label: _appleLabel(context),
            onTap: controller.onTapAppleSignIn,
            enabled: LoginController.isAppleSignInComplete,
          ),
        ],
      ),
      children: const [],
    );
  }
}

String _appleLabel(BuildContext context) => switch (context.languageCode) {
  "es" => "Continuar con Apple (pronto)",
  "pt" => "Continuar com Apple (em breve)",
  _ => "Continue with Apple (soon)",
};

class _SignInOption extends StatelessWidget {
  const _SignInOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: enabled && !isLoading ? onTap : () {},
    child: Opacity(
      opacity: enabled ? 1 : 0.55,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AuthOnboardingColors.navy.withValues(alpha: 0.06),
                ),
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
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AuthOnboardingColors.navy,
                size: 28,
              ),
          ],
        ),
      ),
    ),
  );
}
