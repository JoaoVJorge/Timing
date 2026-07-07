import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/credentials/credentials_controller.dart";
import "package:help_out/shared/widgets/auth_gradient_scaffold.dart";
import "package:help_out/shared/widgets/auth_primary_button.dart";
import "package:help_out/shared/widgets/auth_text_field.dart";
import "package:intl/intl.dart";

class CredentialsPage extends StatelessWidget {
  const CredentialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CredentialsController controller = Get.find();
    final DateFormat dateFormat = DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthGradientScaffold(
        title: context.l10n.credentialsTitle,
        subtitle: context.l10n.credentialsSubtitle,
        bottom: Obx(
          () => AuthPrimaryButton(
            label: context.l10n.finishButton,
            enabled: controller.canSubmit.value,
            isLoading: controller.isSubmitting.value,
            onTap: controller.onSubmit,
          ),
        ),
        children: [
          AuthTextField(
            controller: controller.nameController,
            onChanged: controller.onNameChanged,
            hintText: context.l10n.loginNameHint,
            icon: "address_book",
          ),
          const Gap(16),
          AuthTextField(
            controller: controller.nicknameController,
            hintText:
                "${context.l10n.nicknameHint} (${context.l10n.optionalHint})",
            icon: "special_a",
          ),
          const Gap(16),
          Obx(() {
            final DateTime? date = controller.birthDate.value;
            return AuthTextField(
              hintText: context.l10n.birthDateHint,
              materialIcon: Icons.cake_outlined,
              readOnly: true,
              onTap: () => controller.onPickBirthDate(context),
              valueText: date == null ? null : dateFormat.format(date),
            );
          }),
        ],
      ),
    );
  }
}
