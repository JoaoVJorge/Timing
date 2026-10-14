import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/edit_group/edit_group_controller.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/decoration.dart";

import "package:timing/theme/app_spacing.dart";

class EditGroupPage extends StatelessWidget {
  const EditGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EditGroupController controller = Get.find<EditGroupController>();

    return AppScaffold(
      backgroundColor: context.creationPageBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      topBar: AppTopBar(
        title: context.l10n.editGroupLabel,
        showBackButton: true,
        onBack: controller.appNavigator.back,
      ),
      body: Obx(() {
        if (controller.group.value == null) return const SizedBox.shrink();
        controller.initializeThemeColor(context.colorTokens.primary);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EditorCard(
                      icon: "group",
                      title: context.l10n.editGroupInfoSection,
                      description: context.l10n.editGroupInformationDescription,
                      child: _informationForm(context, controller),
                    ),
                    const Gap(16),
                    CreationColorSection(
                      accent: controller.selectedColor.value,
                      label: context.l10n.colorLabel,
                      onSelect: controller.onSelectColor,
                    ),
                    const Gap(16),
                    _EditorTip(text: context.l10n.editGroupInformationTip),
                    const Gap(16),
                  ],
                ),
              ),
            ),
            const Gap(12),
            _SaveButton(controller: controller),
            const Gap(20),
          ],
        );
      }),
    );
  }

  Widget _informationForm(
    BuildContext context,
    EditGroupController controller,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LabeledField(
        label: context.l10n.groupNameLabel,
        controller: controller.nameController,
        hintText: context.l10n.groupNameExampleHint,
        prefixIcon: AppIcon(
          "group",
          size: 20,
          color: context.colorTokens.textHint,
        ),
      ),
      const Gap(20),
      _LabeledField(
        label: context.l10n.createGroupDescriptionLabel,
        controller: controller.descriptionController,
        hintText: context.l10n.createGroupDescriptionHint,
        minLines: 4,
        maxLines: 6,
        maxLength: 280,
      ),
    ],
  );
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final String icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.primaryVeryLight,
          ),
          child: AppIcon(icon, size: 30, color: context.colorTokens.primary),
        ),
        const Gap(12),
        Text(
          title,
          style: context.textStyles.bodyMedium.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(6),
        Text(
          description,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
            height: 1.45,
          ),
        ),
        const Gap(24),
        child,
      ],
    ),
  );
}

class _EditorTip extends StatelessWidget {
  const _EditorTip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb_rounded,
          color: context.colorTokens.primary,
          size: 24,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.editGroupTipLabel,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                text,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.textHint,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textStyles.bodySmall),
      const Gap(8),
      TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        style: context.textStyles.inputText,
        decoration:
            AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: hintText,
              prefixIcon: prefixIcon,
            ).copyWith(
              contentPadding: AppSpacing.tile,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colorTokens.primary),
              ),
            ),
      ),
    ],
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});

  final EditGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => BounceTap(
      onTap: controller.save,
      pressedScale: 0.98,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: context.colorTokens.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: controller.isSaving.value
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorTokens.primaryForeground,
                ),
              )
            : Text(
                context.l10n.saveChangesButton,
                style: context.textStyles.textPrimaryButton,
              ),
      ),
    ),
  );
}
