import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/shared/widgets/creation/creation_form_widgets.dart";
import "package:help_out/shared/widgets/creation/creation_page_scaffold.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class CreateSubjectPage extends StatelessWidget {
  const CreateSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateSubjectController controller = Get.find();

    return CreationPageScaffold(
      submitButton: Obx(
        () => CreationSubmitButton(
          label: controller.submitLabel(context),
          isLoading: controller.isSaving.value,
          isEnabled: !controller.isSaving.value,
          accent: controller.selectedColor.value,
          onTap: controller.onSubmit,
        ),
      ),
      children: [
        _HeroHeader(controller: controller),
        const Gap(14),
        _NameField(controller: controller),
        const Gap(12),
        _GoalSection(controller: controller),
        const Gap(12),
        _RestSection(controller: controller),
        const Gap(12),
        _ColorSection(controller: controller),
        const Gap(12),
        _IconSection(controller: controller),
        const Gap(12),
        _WallpaperSection(controller: controller),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.controller});

  final CreateSubjectController controller;

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

  final CreateSubjectController controller;

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

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.track_changes_rounded,
        label: controller.isPageBased
            ? context.l10n.createSubjectPagesGoalLabel
            : context.l10n.createSubjectTimeGoalLabel,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PresetRow(
            children:
                (controller.isPageBased
                        ? controller.pageGoalPresets
                        : controller.timeGoalPresets)
                    .map(
                      (value) => CreationSelectableChip(
                        label: controller.isPageBased
                            ? context.l10n.metricPagesValue(value.toInt())
                            : context.l10n.createSubjectHoursValue(
                                value.toInt(),
                              ),
                        isSelected:
                            controller.goal.value.trim() == value.toString(),
                        accent: accent,
                        onTap: () => controller.setGoalPreset(value),
                      ),
                    )
                    .toList(),
          ),
          const Gap(12),
          _GoalInput(controller: controller, accent: accent),
        ],
      ),
    );
  });
}

class _GoalInput extends StatelessWidget {
  const _GoalInput({required this.controller, required this.accent});

  final CreateSubjectController controller;
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
        Icon(Icons.access_time_rounded, color: accent, size: 20),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.goalController,
            keyboardType: controller.isPageBased
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: controller.isPageBased
                  ? context.l10n.goalPagesHint
                  : context.l10n.estimatedHoursGoalHint,
              suffixText: controller.isPageBased
                  ? null
                  : context.l10n.timeUnitHoursSuffix,
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

class _RestSection extends StatelessWidget {
  const _RestSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.emoji_food_beverage_rounded,
        label: context.l10n.createSubjectRestLabel,
        accent: accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PresetRow(
            children: controller.restMinutesOptions
                .map(
                  (minutes) => CreationSelectableChip(
                    label: context.l10n.restMinutesChip(minutes),
                    isSelected: minutes == controller.restMinutes.value,
                    accent: accent,
                    onTap: () => controller.setRestMinutes(minutes),
                  ),
                )
                .toList(),
          ),
          const Gap(12),
          _RestMinutesInput(controller: controller, accent: accent),
        ],
      ),
    );
  });
}

class _RestMinutesInput extends StatelessWidget {
  const _RestMinutesInput({required this.controller, required this.accent});

  final CreateSubjectController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.timer_outlined, color: accent, size: 20),
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
              hintText: context.l10n.customRestMinutesHint,
              suffixText: context.l10n.timeUnitMinutesSuffix,
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

  final CreateSubjectController controller;

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

  final CreateSubjectController controller;

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

  final CreateSubjectController controller;

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

  final CreateSubjectController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Obx(
    () => Wrap(
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

  final CreateSubjectController controller;
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
                      ? const Center(
                          child: AppIcon(
                            "check",
                            size: 18,
                            color: Colors.white,
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
            : context.colorTokens.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? accent : context.colorTokens.borderUnfocused,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
