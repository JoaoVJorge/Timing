import "package:flutter/material.dart";
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
      title: _title(context),
      subtitle: _subtitle(context),
      topVisual: const AuthHeroPlaceholder(icon: Icons.alternate_email_rounded),
      bottom: Obx(
        () => AuthPrimaryButton(
          label: context.l10n.sendCodeButton,
          enabled: controller.canSubmit.value,
          isLoading: controller.isSubmitting.value,
          onTap: controller.onTapSendCode,
        ),
      ),
      children: [
        _EmailInputCard(controller: controller),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              color: AuthOnboardingColors.yellowDark,
              size: 24,
            ),
            const Gap(8),
            Flexible(
              child: Text(
                _securityNote(context),
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

  String _title(BuildContext context) => switch (context.languageCode) {
    "es" => "Tu e-mail",
    "pt" => "Seu e-mail",
    _ => "Your email",
  };

  String _subtitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Ingresa tu e-mail para recibir un código de acceso.",
    "pt" => "Digite seu e-mail para receber um código de acesso.",
    _ => "Enter your email to receive an access code.",
  };

  String _securityNote(BuildContext context) => switch (context.languageCode) {
    "es" => "Enviaremos un código seguro a tu bandeja de entrada.",
    "pt" => "Enviaremos um código seguro para sua caixa de entrada.",
    _ => "We will send a secure code to your inbox.",
  };
}

class _EmailInputCard extends StatelessWidget {
  const _EmailInputCard({required this.controller});

  final PhoneLoginController controller;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: AuthOnboardingDecorations.card,
    child: Container(
      height: 56,
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
          const Icon(
            Icons.mail_outline_rounded,
            color: AuthOnboardingColors.navy,
            size: 24,
          ),
          const Gap(10),
          Expanded(
            child: TextField(
              controller: controller.emailController,
              onChanged: controller.onEmailChanged,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              style: AuthOnboardingTextStyles.fieldValue,
              decoration: InputDecoration(
                hintText: _hint(context),
                hintStyle: AuthOnboardingTextStyles.fieldHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  String _hint(BuildContext context) => switch (context.languageCode) {
    "es" => "tu@email.com",
    "pt" => "voce@email.com",
    _ => "you@email.com",
  };
}
