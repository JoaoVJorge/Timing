import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/edit_group/edit_group_controller.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/decoration.dart";

const Color _fireSequenceColor = Color(0xFFFF6A00);

enum _EditGroupStep { overview, information, activity }

class EditGroupPage extends StatefulWidget {
  const EditGroupPage({super.key});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final EditGroupController controller = Get.find<EditGroupController>();
  _EditGroupStep _step = _EditGroupStep.overview;

  void _showStep(_EditGroupStep step) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _step = step);
  }

  void _back() {
    if (_step == _EditGroupStep.overview) {
      controller.appNavigator.back();
    } else {
      _showStep(_EditGroupStep.overview);
    }
  }

  void _continue() {
    if (controller.nameController.text.trim().isEmpty) {
      controller.appNavigator.showErrorSnackBar(context.l10n.nameRequiredError);
      return;
    }
    _showStep(_EditGroupStep.activity);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _step == _EditGroupStep.overview,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: AppScaffold(
      backgroundColor: context.creationPageBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      topBar: AppTopBar(
        title: context.l10n.editGroupLabel,
        showBackButton: true,
        onBack: _back,
      ),
      body: Obx(() {
        final GroupThemeType? theme = controller.theme;
        if (theme == null) return const SizedBox.shrink();
        controller.initializeThemeColor(context.colorTokens.primary);
        final bool overview = _step == _EditGroupStep.overview;
        final bool information = _step == _EditGroupStep.information;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_step),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (overview || information)
                      _EditorCard(
                        icon: "group",
                        title: context.l10n.editGroupInfoSection,
                        description:
                            context.l10n.editGroupInformationDescription,
                        onTap: overview
                            ? () => _showStep(_EditGroupStep.information)
                            : null,
                        child: information ? _informationForm(context) : null,
                      ),
                    if (overview) const Gap(16),
                    if (overview || !information)
                      _EditorCard(
                        icon: theme.iconName,
                        title: context.l10n.createGroupStepActivity,
                        description: overview
                            ? context.l10n.editGroupActivityOverview
                            : context.l10n.editGroupActivityDescription,
                        onTap: overview
                            ? () => _showStep(_EditGroupStep.activity)
                            : null,
                        child: overview
                            ? null
                            : controller.isLoadingActivity.value
                            ? const _ActivityLoading()
                            : _ActivityForm(controller: controller),
                      ),
                    if (!overview &&
                        !information &&
                        !controller.isLoadingActivity.value) ...[
                      const Gap(16),
                      if (controller.isDailyGoalsTheme) ...[
                        _IntensitySection(controller: controller),
                        const Gap(16),
                      ],
                      _ColorSection(controller: controller),
                    ],
                    if (!information) ...[
                      const Gap(16),
                      _EditorTip(
                        text: overview
                            ? context.l10n.editGroupInformationTip
                            : context.l10n.editGroupActivityTip,
                      ),
                    ],
                    const Gap(16),
                  ],
                ),
              ),
            ),
            const Gap(12),
            _SaveButton(
              controller: controller,
              label: information ? context.l10n.editGroupSaveContinue : null,
              onTap: information ? _continue : null,
            ),
            if (!overview) ...[
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final step in [
                    _EditGroupStep.information,
                    _EditGroupStep.activity,
                  ])
                    Semantics(
                      label: step == _EditGroupStep.information
                          ? context.l10n.editGroupInfoSection
                          : context.l10n.createGroupStepActivity,
                      selected: step == _step,
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step == _step
                              ? context.colorTokens.primary
                              : context.colorTokens.borderUnfocused,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const Gap(20),
          ],
        );
      }),
    ),
  );

  Widget _informationForm(BuildContext context) => Column(
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
    this.description,
    this.child,
    this.onTap,
  });

  final String icon;
  final String title;
  final String? description;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colorTokens.surface,
    borderRadius: BorderRadius.circular(22),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              child: AppIcon(
                icon,
                size: 30,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textStyles.bodyMedium.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (description != null) ...[
                        const Gap(6),
                        Text(
                          description!,
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colorTokens.textHint,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const Gap(12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colorTokens.textBody,
                  ),
                ],
              ],
            ),
            if (child != null) ...[const Gap(24), child!],
          ],
        ),
      ),
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

class _IntensitySection extends StatelessWidget {
  const _IntensitySection({required this.controller});

  final EditGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final DailyTaskSequenceType selected = controller.sequenceType.value;

    return CreationConfigCard(
      accent: context.colorTokens.primary,
      header: CreationSectionHeader(
        icon: Icons.local_fire_department_outlined,
        label: context.l10n.createTaskSequenceTypeLabel,
        accent: context.colorTokens.primary,
      ),
      child: Column(
        children: [
          CreationOptionCard(
            title: context.l10n.createTaskSequenceIntenseLabel,
            description: context.l10n.createTaskSequenceIntenseDescription,
            icon: Icons.local_fire_department_rounded,
            optionColor: _fireSequenceColor,
            isSelected: selected == DailyTaskSequenceType.intense,
            onTap: () =>
                controller.onSelectSequenceType(DailyTaskSequenceType.intense),
          ),
          const Gap(10),
          CreationOptionCard(
            title: context.l10n.createTaskSequenceCasualLabel,
            description: context.l10n.createTaskSequenceCasualDescription,
            icon: Icons.eco_rounded,
            optionColor: context.colorTokens.primary,
            isSelected: selected == DailyTaskSequenceType.casual,
            onTap: () =>
                controller.onSelectSequenceType(DailyTaskSequenceType.casual),
          ),
        ],
      ),
    );
  });
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.controller});

  final EditGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => CreationColorSection(
      accent: controller.selectedColor.value,
      label: context.l10n.colorLabel,
      includePastelColors: true,
      onSelect: (color) => controller.selectedColor.value = color,
    ),
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
        decoration:
            AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: hintText,
              prefixIcon: prefixIcon,
            ).copyWith(
              suffixText: suffixText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colorTokens.primary),
              ),
            ),
      ),
    ],
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
  const _SaveButton({required this.controller, this.label, this.onTap});

  final String? label;
  final VoidCallback? onTap;

  final EditGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => BounceTap(
      onTap: () {
        if (!controller.isSaving.value && !controller.isLoadingActivity.value) {
          if (onTap != null) {
            onTap!();
          } else {
            controller.save();
          }
        }
      },
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
                label ?? context.l10n.saveChangesButton,
                style: context.textStyles.textPrimaryButton,
              ),
      ),
    ),
  );
}
