import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/phone_login/phone_login_controller.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/auth_gradient_scaffold.dart";
import "package:help_out/shared/widgets/auth_text_field.dart";

class PhoneLoginPage extends StatelessWidget {
  const PhoneLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PhoneLoginController controller = Get.find();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthGradientScaffold(
        title: context.l10n.phoneLoginTitle,
        subtitle: context.l10n.phoneLoginSubtitle,
        bottom: Obx(
          () => AppButton(
            variant: AppButtonVariant.onGradient,
            label: context.l10n.sendCodeButton,
            enabled: controller.canSubmit.value,
            isLoading: controller.isSubmitting.value,
            onTap: controller.onTapSendCode,
          ),
        ),
        children: [
          AuthTextField(
            controller: controller.phoneController,
            onChanged: controller.onPhoneChanged,
            hintText: context.l10n.phoneLabel,
            icon: "phone",
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[0-9+()\-\s]")),
            ],
          ),
        ],
      ),
    );
  }
}
