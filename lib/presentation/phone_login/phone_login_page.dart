import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/phone_login/phone_login_controller.dart";
import "package:help_out/shared/widgets/auth_onboarding_widgets.dart";

class PhoneLoginPage extends StatelessWidget {
  const PhoneLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PhoneLoginController controller = Get.find();

    return AuthOnboardingScaffold(
      showBackButton: true,
      title: context.l10n.phoneLoginTitle,
      subtitle: context.l10n.phoneLoginSubtitle,
      topVisual: const AuthHeroPlaceholder(icon: Icons.assignment_rounded),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => AuthPrimaryButton(
              label: context.l10n.sendCodeButton,
              enabled: controller.canSubmit.value,
              isLoading: controller.isSubmitting.value,
              onTap: controller.onTapSendCode,
            ),
          ),
          const Gap(8),
          AuthTextLink(
            label: context.l10n.useSocialLoginButton,
            onTap: Get.back<void>,
          ),
        ],
      ),
      children: [
        _PhoneInputCard(controller: controller),
        const Gap(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: AuthOnboardingColors.yellowDark,
              size: 26,
            ),
            const Gap(10),
            Flexible(
              child: Text(
                context.l10n.phoneSecurityNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AuthOnboardingColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneInputCard extends StatelessWidget {
  const _PhoneInputCard({required this.controller});

  final PhoneLoginController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: AuthOnboardingDecorations.card,
    child: Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AuthOnboardingColors.navy.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Text(
            context.l10n.phoneCountryCodeBrazil,
            style: const TextStyle(
              color: AuthOnboardingColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const Gap(8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AuthOnboardingColors.navy,
            size: 26,
          ),
          const Gap(10),
          Container(
            width: 1,
            height: 24,
            color: AuthOnboardingColors.navy.withValues(alpha: 0.1),
          ),
          const Gap(10),
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              onChanged: controller.onPhoneChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9+()\-\s]")),
              ],
              style: AuthOnboardingTextStyles.fieldValue,
              decoration: InputDecoration(
                hintText: context.l10n.phoneNumberInputHint,
                hintStyle: AuthOnboardingTextStyles.fieldHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Gap(8),
          const Icon(
            Icons.phone_rounded,
            color: AuthOnboardingColors.textMuted,
            size: 26,
          ),
        ],
      ),
    ),
  );
}
