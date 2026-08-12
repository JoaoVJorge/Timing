import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_task/create_task_controller.dart";
import "package:help_out/shared/widgets/creation/creation_form_widgets.dart";
import "package:help_out/shared/widgets/creation/creation_page_scaffold.dart";

class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateTaskController controller = Get.find();
    controller.initializeThemeColor(context.colorTokens.primary);

    return CreationPageScaffold(
      submitButton: Obx(
        () => CreationSubmitButton(
          label: controller.isEditing
              ? context.l10n.editButton
              : context.l10n.addButton,
          isLoading: controller.isSaving.value,
          accent: controller.selectedColor.value,
          onTap: controller.onSubmit,
        ),
      ),
      children: [
        _HeroHeader(controller: controller),
        const Gap(14),
        _NameField(controller: controller),
        const Gap(12),
        _SequenceTypeSection(controller: controller),
        const Gap(12),
        _TargetDaysSection(controller: controller),
        const Gap(12),
        _ColorSection(controller: controller),
      ],
    );
  }
}

class _SequenceTypeSection extends StatelessWidget {
  const _SequenceTypeSection({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.local_fire_department_outlined,
        label: context.l10n.createTaskSequenceTypeLabel,
        accent: accent,
      ),
      child: Column(
        children: [
          _SequenceChoiceCard(
            title: context.l10n.createTaskSequenceIntenseLabel,
            description: context.l10n.createTaskSequenceIntenseDescription,
            icon: Icons.local_fire_department_rounded,
            optionColor: context.colorTokens.primary,
            isSelected:
                controller.sequenceType.value == DailyTaskSequenceType.intense,
            onTap: () =>
                controller.onSelectSequenceType(DailyTaskSequenceType.intense),
          ),
          const Gap(10),
          _SequenceChoiceCard(
            title: context.l10n.createTaskSequenceCasualLabel,
            description: context.l10n.createTaskSequenceCasualDescription,
            icon: Icons.eco_rounded,
            optionColor: const Color(0xFF31D99A),
            isSelected:
                controller.sequenceType.value == DailyTaskSequenceType.casual,
            onTap: () =>
                controller.onSelectSequenceType(DailyTaskSequenceType.casual),
          ),
        ],
      ),
    );
  });
}

class _SequenceChoiceCard extends StatelessWidget {
  const _SequenceChoiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.optionColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color optionColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? context.colorTokens.surface.withValues(alpha: 0.82)
        : context.colorTokens.surface;
    final Color borderColor = isSelected
        ? optionColor.withValues(alpha: 0.68)
        : context.colorTokens.borderUnfocused.withValues(alpha: 0.7);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: optionColor.withValues(alpha: isDark ? 0.16 : 0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: optionColor.withValues(alpha: isDark ? 0.15 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: optionColor.withValues(alpha: isSelected ? 0.72 : 0.2),
                ),
              ),
              child: Icon(icon, color: optionColor, size: 30),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: optionColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textBody,
                      fontWeight: FontWeight.w700,
                      height: 1.24,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? optionColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? optionColor
                      : context.colorTokens.textHint.withValues(alpha: 0.55),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorTokens.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => CreationHeroHeader(
      accent: controller.selectedColor.value,
      imageAsset: "assets/images/goal.png",
      title: context.createTaskHeroTitle,
      subtitle: context.createTaskSubtitle,
    ),
  );
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationNameField(
      controller: controller.nameController,
      hintText: context.l10n.taskNameHint,
      accent: accent,
      icon: Icon(Icons.flag_rounded, color: accent, size: 22),
    );
  });
}

class _TargetDaysSection extends StatelessWidget {
  const _TargetDaysSection({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.track_changes_rounded,
        label: context.l10n.targetDaysLabel,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final int days in CreateTaskController.targetDaysOptions)
                CreationSelectableChip(
                  label: context.l10n.targetDaysChip(days),
                  isSelected: days == controller.targetDays.value,
                  accent: accent,
                  onTap: () => controller.onSelectTargetDays(days),
                ),
              CreationSelectableChip(
                label: context.l10n.targetDaysInfinite,
                isSelected: controller.targetDays.value == 0,
                accent: accent,
                onTap: () => controller.onSelectTargetDays(0),
              ),
            ],
          ),
          const Gap(12),
          _CustomDaysInput(controller: controller, accent: accent),
        ],
      ),
    );
  });
}

class _CustomDaysInput extends StatelessWidget {
  const _CustomDaysInput({required this.controller, required this.accent});

  final CreateTaskController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.calendar_today_rounded, color: accent, size: 19),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.customDaysController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: controller.onCustomDaysChanged,
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.targetDaysHint,
              suffixText: context.daysSuffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: context.colorTokens.textHint.withValues(alpha: 0.62),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.controller});

  final CreateTaskController controller;

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
