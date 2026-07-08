import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/otp/otp_controller.dart";
import "package:help_out/shared/widgets/auth_gradient_scaffold.dart";
import "package:help_out/shared/widgets/app_button.dart";

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthGradientScaffold(
        title: context.l10n.otpTitle,
        subtitle: context.l10n.otpSubtitle(controller.phoneNumber),
        bottom: Obx(
          () => AppButton(
            variant: AppButtonVariant.onGradient,
            label: context.l10n.verifyCodeButton,
            enabled: controller.canSubmit.value,
            isLoading: controller.isSubmitting.value,
            onTap: controller.onTapVerify,
          ),
        ),
        children: [
          _OtpInput(
            controller: controller.codeController,
            onChanged: controller.onCodeChanged,
            length: OtpController.codeLength,
          ),
          const Gap(20),
          Center(
            child: TextButton(
              onPressed: controller.onTapResend,
              child: Text(
                context.l10n.resendCodeButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
                    padding: EdgeInsets.only(right: index == length - 1 ? 0 : 8),
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: hasDigit || isCurrent ? 1 : 0.4,
                          ),
                          width: hasDigit || isCurrent ? 2 : 1.4,
                        ),
                      ),
                      child: Text(
                        hasDigit ? text[index] : "",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
