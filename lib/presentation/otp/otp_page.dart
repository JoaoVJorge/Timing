import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/otp/otp_controller.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/auth_onboarding_widgets.dart";

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find();

    return AuthOnboardingScaffold(
      showBackButton: true,
      title: context.l10n.otpTitle,
      subtitle: context.l10n.otpSubtitle(controller.phoneNumber),
      topVisual: const AuthHeroPlaceholder(icon: Icons.fact_check_rounded),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthTextLink(
            label: context.l10n.resendCodeButton,
            color: AuthOnboardingColors.yellowDark,
            onTap: controller.onTapResend,
          ),
          const Gap(8),
          Obx(
            () => AuthPrimaryButton(
              label: context.l10n.verifyCodeButton,
              enabled: controller.canSubmit.value,
              isLoading: controller.isSubmitting.value,
              onTap: controller.onTapVerify,
            ),
          ),
        ],
      ),
      children: [
        _OtpInput(
          controller: controller.codeController,
          onChanged: controller.onCodeChanged,
          length: OtpController.codeLength,
        ),
        const Gap(16),
        Obx(() {
          final int seconds = controller.secondsRemaining.value;
          final bool isExpired = seconds <= 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpired ? Icons.timer_off_outlined : Icons.schedule_rounded,
                color: isExpired
                    ? AuthOnboardingColors.textMuted
                    : AuthOnboardingColors.yellowDark,
                size: 24,
              ),
              const Gap(8),
              Flexible(
                child: Text(
                  isExpired
                      ? context.l10n.otpCodeExpired
                      : context.l10n.otpCodeValidFor(
                          formatDurationClock(Duration(seconds: seconds)),
                        ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AuthOnboardingColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controller,
    required this.onChanged,
    required this.length,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int length;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: Opacity(
          opacity: 0,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: true,
            keyboardType: TextInputType.number,
            enableInteractiveSelection: false,
            showCursor: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(length),
            ],
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final String text = controller.text;
            return Row(
              children: List.generate(length, (index) {
                final bool hasDigit = index < text.length;
                final bool isCurrent = index == text.length;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == length - 1 ? 0 : 8,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? AuthOnboardingColors.yellow
                              : AuthOnboardingColors.navy.withValues(
                                  alpha: hasDigit ? 0.12 : 0.06,
                                ),
                          width: isCurrent ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AuthOnboardingColors.navy.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        hasDigit ? text[index] : "",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AuthOnboardingColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    ],
  );
}
