import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/join_group/join_group_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/decoration.dart";

class JoinGroupPage extends GetView<JoinGroupController> {
  const JoinGroupPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(title: context.l10n.joinGroupTitle, showBackButton: true),
    body: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.colorTokens.borderUnfocused),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.joinGroupInviteCodeLabel,
                style: context.textStyles.bodyLarge.copyWith(
                  color: context.colorTokens.textBody,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(10),
              TextField(
                controller: controller.codeController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                  LengthLimitingTextInputFormatter(12),
                  _UpperCaseTextFormatter(),
                ],
                decoration: AppInputDecoration.withBorder(
                  tokens: context.colorTokens,
                  hintText: context.l10n.joinGroupCodeHint,
                ),
              ),
              const Gap(16),
              Obx(
                () => _JoinButton(
                  isLoading: controller.isLoading.value,
                  label: context.l10n.joinGroupButton,
                  onTap: controller.join,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.isLoading,
    required this.label,
    required this.onTap,
  });

  final bool isLoading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: isLoading ? () {} : onTap,
    pressedScale: isLoading ? 1 : 0.97,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: context.colorTokens.primaryForeground,
              ),
            )
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textPrimaryButton.copyWith(
                color: context.colorTokens.primaryForeground,
                fontWeight: FontWeight.w900,
              ),
            ),
    ),
  );
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
