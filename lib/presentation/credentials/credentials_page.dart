import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/credentials/credentials_controller.dart";
import "package:help_out/shared/widgets/auth_onboarding_widgets.dart";
import "package:intl/intl.dart";

class CredentialsPage extends StatelessWidget {
  const CredentialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CredentialsController controller = Get.find();
    final DateFormat dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    );

    return AuthOnboardingScaffold(
      showBackButton: true,
      title: context.l10n.credentialsTitle,
      subtitle: context.l10n.credentialsSubtitle,
      topVisual: const AuthHeroPlaceholder(icon: Icons.person_rounded),
      bottom: Obx(
        () => AuthPrimaryButton(
          label: context.l10n.finishButton,
          enabled: controller.canSubmit.value,
          isLoading: controller.isSubmitting.value,
          onTap: controller.onSubmit,
        ),
      ),
      children: [
        AuthFieldCard(
          icon: Icons.person_rounded,
          label: context.l10n.yourNameHint,
          hintText: context.l10n.loginNameHint,
          controller: controller.nameController,
          onChanged: controller.onNameChanged,
        ),
        const Gap(10),
        AuthFieldCard(
          icon: Icons.alternate_email_rounded,
          label: context.l10n.nicknameLabel,
          hintText: context.l10n.nicknameHint,
          controller: controller.nicknameController,
        ),
        const Gap(10),
        Obx(() {
          final DateTime? date = controller.birthDate.value;
          return AuthFieldCard(
            icon: Icons.calendar_month_rounded,
            label: context.l10n.birthDateHint,
            hintText: context.l10n.birthDateHint,
            valueText: date == null ? null : dateFormat.format(date),
            readOnly: true,
            onTap: () => controller.onPickBirthDate(context),
          );
        }),
        const Gap(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuthOnboardingColors.yellow.withValues(alpha: 0.24),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AuthOnboardingColors.navy,
                size: 19,
              ),
            ),
            const Gap(10),
            Flexible(
              child: Text(
                context.l10n.profileEditableLaterNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AuthOnboardingColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
