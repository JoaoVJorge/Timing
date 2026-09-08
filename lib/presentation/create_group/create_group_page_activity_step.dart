part of "create_group_page.dart";

class _ActivityStep extends StatelessWidget {
  const _ActivityStep({
    required this.controller,
    required this.activityNameKey,
    required this.activityGoalKey,
    required this.groupNameKey,
  });

  final CreateGroupController controller;
  final Key activityNameKey;
  final Key activityGoalKey;
  final Key groupNameKey;

  @override
  Widget build(BuildContext context) {
    controller.initializeThemeColor(context.colorTokens.primary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => controller.isDailyGoalsTheme
              ? _DailyGoalActivityForm(
                  controller: controller,
                  nameKey: activityNameKey,
                  goalKey: activityGoalKey,
                )
              : CreateSubjectFormContent(
                  controller: controller,
                  showHero: false,
                  nameKey: activityNameKey,
                  goalKey: activityGoalKey,
                ),
        ),
        const Gap(16),
        _SectionCard(
          key: groupNameKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.groupNameLabel,
                style: context.textStyles.bodySmall,
              ),
              const Gap(8),
              TextField(
                controller: controller.groupNameController,
                onChanged: controller.onGroupNameChanged,
                style: context.textStyles.inputText,
                decoration: AppInputDecoration.withBorder(
                  tokens: context.colorTokens,
                  hintText: context.l10n.groupNameExampleHint,
                  prefixIcon: AppIcon(
                    "group",
                    size: 20,
                    color: context.colorTokens.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyGoalActivityForm extends StatelessWidget {
  const _DailyGoalActivityForm({
    required this.controller,
    required this.nameKey,
    required this.goalKey,
  });

  final CreateGroupController controller;
  final Key nameKey;
  final Key goalKey;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeyedSubtree(
          key: nameKey,
          child: CreationNameField(
            controller: controller.activityNameController,
            hintText: context.l10n.taskNameHint,
            accent: accent,
            icon: Icon(Icons.flag_rounded, color: accent, size: 22),
          ),
        ),
        const Gap(12),
        CreationConfigCard(
          accent: accent,
          header: CreationSectionHeader(
            icon: Icons.track_changes_rounded,
            label: context.l10n.targetDaysLabel,
            accent: accent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KeyedSubtree(
                key: goalKey,
                child: _DailyGoalTargetInput(
                  controller: controller,
                  accent: accent,
                ),
              ),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final int days
                      in CreateGroupController.dailyGoalTargetDaysOptions)
                    Obx(
                      () => CreationSelectableChip(
                        label: context.l10n.targetDaysChip(days),
                        isSelected:
                            controller.activityGoal.value.trim() ==
                            days.toString(),
                        accent: accent,
                        onTap: () => controller.setGoalPreset(days),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Gap(12),
        Obx(
          () => CreationColorSection(
            accent: controller.selectedColor.value,
            label: context.l10n.colorLabel,
            includePastelColors: true,
            onSelect: (color) => controller.selectedColor.value = color,
          ),
        ),
      ],
    );
  });
}

class _DailyGoalTargetInput extends StatelessWidget {
  const _DailyGoalTargetInput({required this.controller, required this.accent});

  final CreateGroupController controller;
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
            controller: controller.activityGoalController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
