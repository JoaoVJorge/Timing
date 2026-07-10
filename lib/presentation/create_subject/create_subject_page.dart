import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class CreateSubjectPage extends StatelessWidget {
  const CreateSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateSubjectController controller = Get.find();

    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: context.colorTokens.white,
      bottomBar: Obx(
        () => _SubmitButton(
          label: controller.submitLabel(context),
          isLoading: controller.isSaving.value,
          isEnabled: !controller.isSaving.value,
          onTap: controller.onSubmit,
        ),
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _BackButton(),
                const Gap(8),
                Expanded(
                  child: Text(
                    controller.title(context),
                    style: TextStyle(
                      color: context.colorTokens.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              controller.subtitle(context),
              style: TextStyle(
                color: context.colorTokens.textHint,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const Gap(20),
            _NameField(controller: controller),
            const Gap(20),
            _GoalSection(controller: controller),
            const Gap(20),
            const _Divider(),
            const Gap(20),
            _RestSection(controller: controller),
            const Gap(20),
            const _Divider(),
            const Gap(20),
            _ColorSection(controller: controller),
            const Gap(20),
            _IconSection(controller: controller),
            const Gap(20),
            _WallpaperSection(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: appNavigator.back,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: AppIcon(
          "left_back",
          size: 20,
          color: context.colorTokens.primary,
        ),
      ),
    ),
  );
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color color = controller.selectedColor.value;
    final String iconName = controller.selectedIconName.value;
    final IconData? icon = SubjectIcons.byName(iconName);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colorTokens.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.65)),
            ),
            child: Center(
              child: icon == null
                  ? AppIcon(iconName, color: color, size: 22)
                  : Icon(icon, color: color, size: 22),
            ),
          ),
          const Gap(12),
          Expanded(
            child: TextField(
              controller: controller.nameController,
              autofocus: true,
              style: TextStyle(
                color: context.colorTokens.textBody,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: controller.nameHint(context),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: context.colorTokens.textHint.withValues(alpha: 0.62),
                  fontSize: 15,
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

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        icon: Icons.track_changes_rounded,
        label: controller.isPageBased
            ? context.l10n.createSubjectPagesGoalLabel
            : context.l10n.createSubjectTimeGoalLabel,
      ),
      const Gap(12),
      Obx(
        () => _PresetRow(
          children:
              (controller.isPageBased
                      ? controller.pageGoalPresets
                      : controller.timeGoalPresets)
                  .map(
                    (value) => _SelectableChip(
                      label: controller.isPageBased
                          ? context.l10n.metricPagesValue(value.toInt())
                          : context.l10n.createSubjectHoursValue(value.toInt()),
                      isSelected:
                          controller.goal.value.trim() == value.toString(),
                      onTap: () => controller.setGoalPreset(value),
                    ),
                  )
                  .toList(),
        ),
      ),
      const Gap(12),
      _GoalInput(controller: controller),
    ],
  );
}

class _GoalInput extends StatelessWidget {
  const _GoalInput({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          color: context.colorTokens.textHint.withValues(alpha: 0.62),
          size: 20,
        ),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.goalController,
            keyboardType: controller.isPageBased
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: controller.isPageBased
                  ? context.l10n.goalPagesHint
                  : context.l10n.estimatedHoursGoalHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: context.colorTokens.textHint.withValues(alpha: 0.62),
                fontSize: 15,
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        icon: Icons.emoji_food_beverage_rounded,
        label: context.l10n.createSubjectRestLabel,
      ),
      const Gap(12),
      Obx(
        () => _PresetRow(
          children: controller.restMinutesOptions
              .map(
                (minutes) => _SelectableChip(
                  label: context.l10n.restMinutesChip(minutes),
                  isSelected: minutes == controller.restMinutes.value,
                  onTap: () => controller.restMinutes.value = minutes,
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        icon: Icons.palette_outlined,
        label: context.l10n.colorLabel,
      ),
      const Gap(14),
      Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: SubjectColors.values
                .map(
                  (color) => _ColorChoice(
                    color: color,
                    isSelected:
                        color.toARGB32() ==
                        controller.selectedColor.value.toARGB32(),
                    onTap: () => controller.selectedColor.value = color,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ],
  );
}

class _IconSection extends StatelessWidget {
  const _IconSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        icon: Icons.star_border_rounded,
        label: context.l10n.iconLabel,
      ),
      const Gap(12),
      _IconSelector(controller: controller),
    ],
  );
}

class _WallpaperSection extends StatelessWidget {
  const _WallpaperSection({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        icon: Icons.image_outlined,
        label: context.l10n.wallpaperLabel,
      ),
      const Gap(12),
      _WallpaperSelector(controller: controller),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 22, color: context.colorTokens.primary),
      const Gap(10),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colorTokens.textBody,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 1,
    color: context.colorTokens.primary.withValues(alpha: 0.08),
  );
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

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.textBody,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color.withValues(alpha: 0.18) : color,
        border: Border.all(
          color: isSelected ? context.colorTokens.primary : color,
          width: isSelected ? 3 : 0,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
        ],
      ),
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Center(
                child: AppIcon("check", size: 18, color: Colors.white),
              ),
            )
          : null,
    ),
  );
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.iconSuggestions.map((iconName) {
        final bool isSelected = iconName == controller.selectedIconName.value;
        return _IconChoice(
          iconName: iconName,
          icon: SubjectIcons.byName(iconName),
          isSelected: isSelected,
          onTap: () => controller.selectedIconName.value = iconName,
        );
      }).toList(),
    ),
  );
}

class _WallpaperSelector extends StatelessWidget {
  const _WallpaperSelector({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: List.generate(TimerWallpapers.values.length, (index) {
          final bool isSelected = index == controller.wallpaperIndex.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index == TimerWallpapers.values.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => controller.wallpaperIndex.value = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 68,
                height: 88,
                decoration: BoxDecoration(
                  gradient: TimerWallpapers.byIndex(index),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? context.colorTokens.primary
                        : context.colorTokens.borderUnfocused,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: AppIcon("check", size: 18, color: Colors.white),
                      )
                    : null,
              ),
            ),
          );
        }),
      ),
    ),
  );
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconName,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String iconName;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
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
                size: 20,
                color: isSelected
                    ? context.colorTokens.primary
                    : context.colorTokens.iconDisabled,
              )
            : Icon(
                icon,
                size: 20,
                color: isSelected
                    ? context.colorTokens.primary
                    : context.colorTokens.iconDisabled,
              ),
      ),
    ),
  );
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isEnabled && !isLoading ? onTap : null,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1 : 0.62,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colorTokens.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.primary.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorTokens.white,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colorTokens.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    ),
  );
}
