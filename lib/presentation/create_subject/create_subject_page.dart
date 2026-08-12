import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";
import "package:help_out/presentation/create_subject/subject_creation_form_controller.dart";
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
    controller.initializeThemeColor(context.colorTokens.primary);

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
      children: [CreateSubjectFormContent(controller: controller)],
    );
  }
}

class CreateSubjectFormContent extends StatelessWidget {
  const CreateSubjectFormContent({
    required this.controller,
    this.showHero = true,
    super.key,
  });

  final SubjectCreationFormController controller;
  final bool showHero;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showHero) ...[
        _HeroHeader(controller: controller),
        const Gap(14),
      ],
      _NameField(controller: controller),
      const Gap(12),
      _ActivityTypeSection(controller: controller),
      const Gap(12),
      _GoalSection(controller: controller),
      if (!controller.isPageBased) ...[
        const Gap(12),
        _FocusSessionCountSection(controller: controller),
        const Gap(12),
        _RestSection(controller: controller),
      ],
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
          _ActivityTypeOption(
            title: context.l10n.activityTypeDailyLabel,
            description: context.l10n.activityTypeDailyDescription,
            icon: Icons.wb_sunny_outlined,
            isSelected:
                controller.activityType.value == SubjectActivityType.daily,
            accent: accent,
            onTap: () => controller.setActivityType(SubjectActivityType.daily),
          ),
          const Gap(10),
          _ActivityTypeOption(
            title: context.l10n.activityTypePermanentLabel,
            description: context.l10n.activityTypePermanentDescription,
            icon: Icons.done_all_rounded,
            isSelected:
                controller.activityType.value == SubjectActivityType.permanent,
            accent: accent,
            onTap: () =>
                controller.setActivityType(SubjectActivityType.permanent),
          ),
        ],
      ),
    );
  });
}

class _ActivityTypeOption extends StatelessWidget {
  const _ActivityTypeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? accent.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.2
                    : 0.1,
              )
            : context.colorTokens.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accent : context.colorTokens.borderUnfocused,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.2
                          : 0.1,
                    )
                  : context.colorTokens.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.7)
                    : context.colorTokens.borderUnfocused,
              ),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.controller});

  final SubjectCreationFormController controller;

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
                            ? value.toString()
                            : context.l10n.restMinutesChip(value),
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
        Icon(
          controller.isPageBased
              ? Icons.menu_book_rounded
              : Icons.access_time_rounded,
          color: accent,
          size: 20,
        ),
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
                  : context.l10n.estimatedHoursGoalHint,
              suffixText: controller.isPageBased
                  ? context.l10n.pagesSuffix
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
        accent: accent,
      ),
      child: _PresetRow(
        children: controller.focusSessionCountOptions
            .map(
              (count) => CreationSelectableChip(
                label: context.l10n.timerSessionCounter(count, count),
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

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.self_improvement_rounded,
        label: context.l10n.createSubjectRestLabel,
        accent: accent,
      ),
      child: _PresetRow(
        children: controller.restMinutesOptions
            .map(
              (minutes) => CreationSelectableChip(
                label: context.l10n.restMinutesChip(minutes),
                isSelected: controller.restMinutes.value == minutes,
                accent: accent,
                onTap: () => controller.setRestMinutes(minutes),
              ),
            )
            .toList(),
      ),
    );
  });
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.controller});

  final SubjectCreationFormController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => CreationColorSection(
      accent: controller.selectedColor.value,
      label: context.l10n.colorLabel,
      extraColors: [context.colorTokens.primary],
      includePastelColors: true,
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
