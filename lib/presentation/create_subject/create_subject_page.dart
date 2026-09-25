import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/create_subject/create_subject_controller.dart";
import "package:timing/presentation/create_subject/subject_creation_form_controller.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/centered_wrap_grid.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/shared/widgets/creation/creation_page_scaffold.dart";
import "package:timing/theme/subject_icons.dart";
import "package:timing/theme/timer_wallpapers.dart";

class CreateSubjectPage extends StatelessWidget {
  const CreateSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateSubjectController controller = Get.find();
    final GlobalKey nameKey = GlobalKey();
    final GlobalKey goalKey = GlobalKey();
    controller.initializeThemeColor(context.colorTokens.primary);

    return CreationPageScaffold(
      submitButton: Obx(
        () => CreationSubmitButton(
          label: controller.submitLabel(context),
          isLoading: controller.isSaving.value,
          isEnabled: !controller.isSaving.value,
          accent: controller.selectedColor.value,
          onTap: () async {
            await _scrollToFirstInvalidSection(
              controller: controller,
              nameKey: nameKey,
              goalKey: goalKey,
            );
            await controller.onSubmit();
          },
        ),
      ),
      children: [
        CreateSubjectFormContent(
          controller: controller,
          nameKey: nameKey,
          goalKey: goalKey,
        ),
      ],
    );
  }

  Future<void> _scrollToFirstInvalidSection({
    required CreateSubjectController controller,
    required GlobalKey nameKey,
    required GlobalKey goalKey,
  }) async {
    final GlobalKey? targetKey = controller.name.value.trim().isEmpty
        ? nameKey
        : !controller.hasValidGoal
        ? goalKey
        : null;

    final BuildContext? targetContext = targetKey?.currentContext;
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

class CreateSubjectFormContent extends StatelessWidget {
  const CreateSubjectFormContent({
    required this.controller,
    this.showHero = true,
    this.nameKey,
    this.goalKey,
    super.key,
  });

  final SubjectCreationFormController controller;
  final bool showHero;
  final Key? nameKey;
  final Key? goalKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showHero) ...[_HeroHeader(controller: controller), const Gap(14)],
      KeyedSubtree(
        key: nameKey,
        child: _NameField(controller: controller),
      ),
      const Gap(12),
      _ActivityTypeSection(controller: controller),
      const Gap(12),
      KeyedSubtree(
        key: goalKey,
        child: _GoalSection(controller: controller),
      ),
      _FocusRoutineSections(controller: controller),
      const Gap(12),
      _ColorSection(controller: controller),
      const Gap(12),
      _IconSection(controller: controller),
      const Gap(12),
      _WallpaperSection(controller: controller),
    ],
  );
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => CreationHeroHeader(
      accent: controller.selectedColor.value,
      imageAsset: _heroAsset(controller.category),
      title: _heroTitle(context),
      subtitle: controller.subtitle(context),
    ),
  );

  String _heroTitle(BuildContext context) =>
      controller.title(context).replaceFirst(" ", "\n");

  String _heroAsset(TimeCategoryType category) => switch (category) {
    TimeCategoryType.studying => "assets/images/notebook.png",
    TimeCategoryType.exercises => "assets/images/tennis.png",
    TimeCategoryType.reading => "assets/images/book.png",
    TimeCategoryType.hobbies => "assets/images/godet.png",
  };
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;
    final String iconName = controller.selectedIconName.value;
    final IconData? icon = SubjectIcons.byName(iconName);

    return CreationNameField(
      controller: controller.nameController,
      hintText: controller.nameHint(context),
      accent: accent,
      icon: icon == null
          ? AppIcon(iconName, color: accent, size: 22)
          : Icon(icon, color: accent, size: 22),
    );
  });
}

class _ActivityTypeSection extends StatelessWidget {
  const _ActivityTypeSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.repeat_rounded,
        label: context.l10n.activityTypeLabel,
        accent: accent,
      ),
      child: Column(
        children: [
          CreationOptionCard(
            title: context.l10n.activityTypeDailyLabel,
            description: _dailyDescription(context),
            icon: Icons.wb_sunny_outlined,
            optionColor: accent,
            isSelected:
                controller.activityType.value == SubjectActivityType.daily,
            onTap: () => controller.setActivityType(SubjectActivityType.daily),
            iconSize: 24,
            iconBoxSize: 42,
          ),
          const Gap(10),
          CreationOptionCard(
            title: context.l10n.activityTypePermanentLabel,
            description: _permanentDescription(context),
            icon: Icons.done_all_rounded,
            optionColor: accent,
            isSelected:
                controller.activityType.value == SubjectActivityType.permanent,
            onTap: () =>
                controller.setActivityType(SubjectActivityType.permanent),
            iconSize: 24,
            iconBoxSize: 42,
          ),
        ],
      ),
    );
  });

  String _dailyDescription(BuildContext context) =>
      switch (controller.category) {
        TimeCategoryType.exercises =>
          context.l10n.activityTypeDailyDescriptionExercises,
        TimeCategoryType.hobbies =>
          context.l10n.activityTypeDailyDescriptionHobbies,
        _ => context.l10n.activityTypeDailyDescriptionStudying,
      };

  String _permanentDescription(BuildContext context) =>
      switch (controller.category) {
        TimeCategoryType.exercises =>
          context.l10n.activityTypePermanentDescriptionExercises,
        TimeCategoryType.hobbies =>
          context.l10n.activityTypePermanentDescriptionHobbies,
        _ => context.l10n.activityTypePermanentDescriptionStudying,
      };
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;
    final SubjectActivityType activityType = controller.activityType.value;
    final bool isPermanent = activityType == SubjectActivityType.permanent;
    final List<int> presets = controller.isPageBased
        ? controller.pageGoalPresets
        : isPermanent
        ? controller.totalTimeGoalPresets
        : controller.timeGoalPresets;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.track_changes_rounded,
        label: controller.isPageBased
            ? context.l10n.createSubjectPagesGoalLabel
            : isPermanent
            ? context.l10n.createSubjectTotalTimeGoalTitle
            : context.l10n.createSubjectTimeGoalLabel,
        description: controller.isPageBased
            ? null
            : isPermanent
            ? _totalTimeGoalDescription(context)
            : context.l10n.subjectSectionDurationDescription,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GoalInput(controller: controller, accent: accent),
          const Gap(12),
          _PresetRow(
            children: presets
                .map(
                  (value) => CreationSelectableChip(
                    label: controller.isPageBased
                        ? value.toString()
                        : isPermanent
                        ? context.l10n.createSubjectHoursValue(value)
                        : context.l10n.restMinutesChip(value),
                    isSelected:
                        controller.goal.value.trim() == value.toString(),
                    accent: accent,
                    onTap: () => controller.setGoalPreset(value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  });

  String _totalTimeGoalDescription(BuildContext context) =>
      switch (controller.category) {
        TimeCategoryType.exercises =>
          context.l10n.createSubjectTotalTimeGoalLabelExercises,
        TimeCategoryType.hobbies =>
          context.l10n.createSubjectTotalTimeGoalLabelHobbies,
        _ => context.l10n.createSubjectTotalTimeGoalLabelStudying,
      };
}

class _GoalInput extends StatelessWidget {
  const _GoalInput({required this.controller, required this.accent});

  final SubjectCreationFormController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Obx(() {
    final bool isPermanent =
        controller.activityType.value == SubjectActivityType.permanent;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorTokens.scaffold.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          controller.isPageBased
              ? AppIcon("open-book", color: accent, size: 20)
              : Icon(Icons.access_time_rounded, color: accent, size: 20),
          const Gap(12),
          Expanded(
            child: TextField(
              controller: controller.goalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: context.colorTokens.textBody,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: controller.isPageBased
                    ? context.l10n.goalPagesHint
                    : isPermanent
                    ? context.l10n.createSubjectTotalHoursGoalHint
                    : context.l10n.estimatedHoursGoalHint,
                suffixText: controller.isPageBased
                    ? context.l10n.pagesSuffix
                    : isPermanent
                    ? context.l10n.timeUnitHoursSuffix
                    : context.l10n.timeUnitMinutesSuffix,
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
  });
}

class _FocusRoutineSections extends StatelessWidget {
  const _FocusRoutineSections({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final SubjectActivityType activityType = controller.activityType.value;
    if (controller.isPageBased ||
        controller.category == TimeCategoryType.hobbies ||
        activityType == SubjectActivityType.permanent) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Gap(12),
        _FocusSessionCountSection(controller: controller),
        const Gap(12),
        _RestSection(controller: controller),
      ],
    );
  });
}

class _FocusSessionCountSection extends StatelessWidget {
  const _FocusSessionCountSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.repeat_rounded,
        label: context.l10n.focusSessionCountLabel,
        description: context.l10n.subjectSessionCountDescription,
        accent: accent,
      ),
      child: _PresetRow(
        children: controller.focusSessionCountOptions
            .map(
              (count) => CreationSelectableChip(
                label: count.toString(),
                isSelected: controller.focusSessionCount.value == count,
                accent: accent,
                onTap: () => controller.setFocusSessionCount(count),
              ),
            )
            .toList(),
      ),
    );
  });
}

class _RestSection extends StatelessWidget {
  const _RestSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;
    final bool usesSeconds = controller.category == TimeCategoryType.exercises;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.self_improvement_rounded,
        label: context.l10n.createSubjectRestLabel,
        description: context.l10n.subjectRestDurationDescription,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (usesSeconds) ...[
            _RestInput(controller: controller, accent: accent),
            const Gap(12),
          ],
          _PresetRow(
            children: controller.restMinutesOptions
                .map(
                  (value) => CreationSelectableChip(
                    label: _formatRestValue(
                      context,
                      value,
                      usesSeconds: usesSeconds,
                    ),
                    isSelected: controller.restMinutes.value == value,
                    accent: accent,
                    onTap: () => controller.setRestMinutes(value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  });
}

String _formatRestValue(
  BuildContext context,
  int value, {
  required bool usesSeconds,
}) => usesSeconds ? "${value}s" : context.l10n.restMinutesChip(value);

class _RestInput extends StatelessWidget {
  const _RestInput({required this.controller, required this.accent});

  final SubjectCreationFormController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.hourglass_bottom_rounded, color: accent, size: 20),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.restMinutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.createSubjectPauseDurationHint,
              suffixText: "s",
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

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => CreationColorSection(
      accent: controller.selectedColor.value,
      label: context.l10n.colorLabel,
      onSelect: (color) => controller.selectedColor.value = color,
    ),
  );
}

class _IconSection extends StatelessWidget {
  const _IconSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.star_border_rounded,
        label: context.l10n.iconLabel,
        accent: accent,
      ),
      child: _IconSelector(controller: controller, accent: accent),
    );
  });
}

class _WallpaperSection extends StatelessWidget {
  const _WallpaperSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.image_outlined,
        label: context.l10n.wallpaperLabel,
        accent: accent,
      ),
      child: _WallpaperSelector(controller: controller, accent: accent),
    );
  });
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int index = 0; index < children.length; index++) ...[
        Expanded(child: children[index]),
        if (index != children.length - 1) const Gap(8),
      ],
    ],
  );
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({required this.controller, required this.accent});

  final SubjectCreationFormController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Obx(
    () => CenteredBalancedRows(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String iconName in controller.iconSuggestions)
          _IconChoice(
            iconName: iconName,
            icon: SubjectIcons.byName(iconName),
            isSelected: iconName == controller.selectedIconName.value,
            accent: accent,
            onTap: () => controller.selectedIconName.value = iconName,
          ),
      ],
    ),
  );
}

class _WallpaperSelector extends StatelessWidget {
  const _WallpaperSelector({required this.controller, required this.accent});

  final SubjectCreationFormController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double gap = 8;
      final double itemWidth =
          (constraints.maxWidth - gap * (TimerWallpapers.values.length - 1)) /
          TimerWallpapers.values.length;

      return Obx(() {
        return Row(
          children: List.generate(TimerWallpapers.values.length, (index) {
            final bool isSelected = index == controller.wallpaperIndex.value;
            return Padding(
              padding: EdgeInsets.only(
                right: index == TimerWallpapers.values.length - 1 ? 0 : gap,
              ),
              child: BounceTap(
                onTap: () => controller.wallpaperIndex.value = index,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: itemWidth,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: TimerWallpapers.byIndex(index),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? accent
                          : context.colorTokens.borderUnfocused,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: AppIcon(
                            "check",
                            size: 18,
                            color: TimerWallpapers.usesDarkForeground(index)
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        );
      });
    },
  );
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconName,
    required this.isSelected,
    required this.onTap,
    required this.accent,
    this.icon,
  });

  final String iconName;
  final IconData? icon;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 46,
      decoration: BoxDecoration(
        color: isSelected
            ? accent.withValues(alpha: 0.12)
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? accent : context.colorTokens.borderUnfocused,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(
        child: icon == null
            ? AppIcon(
                iconName,
                size: 22,
                color: isSelected ? accent : context.colorTokens.iconDisabled,
              )
            : Icon(
                icon,
                size: 22,
                color: isSelected ? accent : context.colorTokens.iconDisabled,
              ),
      ),
    ),
  );
}
