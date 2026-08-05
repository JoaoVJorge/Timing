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
        _GoalTypeSection(controller: controller),
        const Gap(12),
        _TargetDaysSection(controller: controller),
        const Gap(12),
        _ColorSection(controller: controller),
      ],
    );
  }
}

class _GoalTypeSection extends StatelessWidget {
  const _GoalTypeSection({required this.controller});

  final CreateTaskController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.repeat_rounded,
        label: _goalTypeLabel(context),
        accent: accent,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          CreationSelectableChip(
            label: _dailyLabel(context),
            isSelected: controller.goalType.value == DailyTaskGoalType.daily,
            accent: accent,
            onTap: () => controller.onSelectGoalType(DailyTaskGoalType.daily),
          ),
          CreationSelectableChip(
            label: _totalLabel(context),
            isSelected: controller.goalType.value == DailyTaskGoalType.total,
            accent: accent,
            onTap: () => controller.onSelectGoalType(DailyTaskGoalType.total),
          ),
        ],
      ),
    );
  });

  String _goalTypeLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Goal type",
    "es" => "Tipo de meta",
    _ => "Tipo da meta",
  };

  String _dailyLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Daily",
    "es" => "Diaria",
    _ => "Diaria",
  };

  String _totalLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Total",
    "es" => "Total",
    _ => "Total",
  };
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
    if (controller.goalType.value == DailyTaskGoalType.daily) {
      return const SizedBox.shrink();
    }

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
      extraColors: [context.colorTokens.primary],
      onSelect: (color) => controller.selectedColor.value = color,
    ),
  );
}
