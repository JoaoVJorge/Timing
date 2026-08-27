import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/edit_group/edit_group_controller.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_surfaces.dart";
import "package:timing/theme/decoration.dart";

class EditGroupPage extends GetView<EditGroupController> {
  const EditGroupPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(title: context.l10n.editGroupLabel, showBackButton: true),
    body: Obx(() {
      final GroupThemeType? theme = controller.theme;
      if (theme == null) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: context.l10n.editGroupInfoSection,
                    icon: AppIcon(
                      "group",
                      size: 20,
                      color: context.colorTokens.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledField(
                          label: context.l10n.scheduleTitleHint,
                          controller: controller.nameController,
                          hintText: context.l10n.groupNameExampleHint,
                          prefixIcon: AppIcon(
                            "group",
                            size: 18,
                            color: context.colorTokens.textHint,
                          ),
                        ),
                        const Gap(14),
                        _LabeledField(
                          label: context.l10n.createGroupDescriptionLabel,
                          controller: controller.descriptionController,
                          hintText: context.l10n.createGroupDescriptionHint,
                          minLines: 3,
                          maxLines: 5,
                          maxLength: 280,
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  _SectionCard(
                    title: context.l10n.createGroupStepActivity,
                    icon: AppIcon(
                      theme.iconName,
                      size: 20,
                      color: context.colorTokens.primary,
                    ),
                    trailing: _ThemeBadge(theme: theme),
                    child: controller.isLoadingActivity.value
                        ? const _ActivityLoading()
                        : _ActivityForm(controller: controller),
                  ),
                ],
              ),
            ),
          ),
          const Gap(12),
          _SaveButton(controller: controller),
          const Gap(16),
        ],
      );
    }),
  );
}

class _ActivityForm extends StatelessWidget {
  const _ActivityForm({required this.controller});

  final EditGroupController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LabeledField(
        label: context.l10n.createGroupActivityNameLabel,
        controller: controller.activityNameController,
        hintText: context.l10n.createGroupActivityNameLabel,
        prefixIcon: Icon(
          Icons.flag_rounded,
          size: 19,
          color: context.colorTokens.textHint,
        ),
      ),
      const Gap(14),
      _LabeledField(
        label: controller.isDailyGoalsTheme
            ? context.l10n.targetDaysLabel
            : controller.isReadingTheme
            ? context.l10n.createGroupPagesGoalLabel
            : context.l10n.createGroupFocusGoalLabel,
        controller: controller.activityGoalController,
        hintText: controller.isDailyGoalsTheme
            ? context.l10n.targetDaysHint
            : "0",
        suffixText: controller.goalSuffix,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        prefixIcon: Icon(
          Icons.track_changes_rounded,
          size: 19,
          color: context.colorTokens.textHint,
        ),
      ),
      if (controller.showRestAndSessions) ...[
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: context.l10n.restLabel,
                controller: controller.restController,
                hintText: "0",
                suffixText: controller.restSuffix,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const Gap(12),
            Expanded(
              child: _LabeledField(
                label: context.l10n.sessionsLabel,
                controller: controller.sessionsController,
                hintText: "1",
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: icon,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(fontSize: 18),
              ),
            ),
            if (trailing != null) ...[const Gap(10), trailing!],
          ],
        ),
        const Gap(16),
        child,
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
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        style: context.textStyles.inputText,
        decoration: AppInputDecoration.withBorder(
          tokens: context.colorTokens,
          hintText: hintText,
          prefixIcon: prefixIcon,
        ).copyWith(suffixText: suffixText),
      ),
    ],
  );
}

class _ThemeBadge extends StatelessWidget {
  const _ThemeBadge({required this.theme});

  final GroupThemeType theme;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      theme.localizedLabel(context),
      style: context.textStyles.bodySmall.copyWith(
        color: context.colorTokens.primary,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ActivityLoading extends StatelessWidget {
  const _ActivityLoading();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 96,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.colorTokens.primary,
      ),
    ),
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});

  final EditGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => BounceTap(
      onTap: () {
        if (!controller.isSaving.value) {
          controller.save();
        }
      },
      pressedScale: 0.98,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: context.colorTokens.primaryGradient,
          borderRadius: BorderRadius.circular(18),
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
