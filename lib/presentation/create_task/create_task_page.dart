import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/create_task/create_task_controller.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/shared/widgets/creation/creation_page_scaffold.dart";

const Color _fireSequenceColor = Color(0xFFFF6A00);

class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateTaskController controller = Get.find();
    final GlobalKey nameKey = GlobalKey();
    controller.initializeThemeColor(context.colorTokens.primary);

    return CreationPageScaffold(
      submitButton: Obx(
        () => CreationSubmitButton(
          label: controller.isEditing
              ? context.l10n.editButton
              : context.l10n.addButton,
          isLoading: controller.isSaving.value,
          accent: controller.selectedColor.value,
          onTap: () async {
            await _scrollToFirstInvalidSection(
              controller: controller,
              nameKey: nameKey,
            );
            await controller.onSubmit();
          },
        ),
      ),
      children: [
        _HeroHeader(controller: controller),
        const Gap(14),
        KeyedSubtree(
          key: nameKey,
          child: _NameField(controller: controller),
        ),
        const Gap(12),
        _SequenceTypeSection(controller: controller),
        const Gap(12),
        _TargetDaysSection(controller: controller),
        const Gap(12),
        _ColorSection(controller: controller),
      ],
    );
  }

  Future<void> _scrollToFirstInvalidSection({
    required CreateTaskController controller,
    required GlobalKey nameKey,
  }) async {
    if (controller.nameController.text.trim().isNotEmpty) {
      return;
    }

    final BuildContext? targetContext = nameKey.currentContext;
    if (targetContext == null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
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
          CreationOptionCard(
            title: context.l10n.createTaskSequenceIntenseLabel,
            description: context.l10n.createTaskSequenceIntenseDescription,
            icon: Icons.local_fire_department_rounded,
            optionColor: _fireSequenceColor,
            isSelected:
                controller.sequenceType.value == DailyTaskSequenceType.intense,
            onTap: () =>
                controller.onSelectSequenceType(DailyTaskSequenceType.intense),
          ),
          const Gap(10),
          CreationOptionCard(
            title: context.l10n.createTaskSequenceCasualLabel,
            description: context.l10n.createTaskSequenceCasualDescription,
            icon: Icons.eco_rounded,
            optionColor: context.colorTokens.primary,
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
          _CustomDaysInput(controller: controller, accent: accent),
          const Gap(12),
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
