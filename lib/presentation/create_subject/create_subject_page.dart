import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/subject_color_selector.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class CreateSubjectPage extends StatelessWidget {
  const CreateSubjectPage({super.key});

  static const List<num> _timeGoalPresets = [1, 3, 5, 10];
  static const List<num> _pageGoalPresets = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    final CreateSubjectController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(title: controller.title(context), showBackButton: true),
      bottomBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: controller.submitLabel(context),
              enabled: !controller.isSaving.value,
              isLoading: controller.isSaving.value,
              onTap: controller.onSubmit,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.subtitle(context),
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(20),
            _SubjectPreview(controller: controller),
            const Gap(20),
            _FormSection(
              title: context.l10n.createSubjectBasicSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: "${controller.nameLabel(context)} *"),
                  const Gap(8),
                  TextField(
                    controller: controller.nameController,
                    autofocus: true,
                    decoration: AppInputDecoration.withBorder(
                      tokens: context.colorTokens,
                      hintText: controller.nameHint(context),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            _FormSection(
              title: context.l10n.createSubjectGoalSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(
                    text:
                        "${controller.isPageBased ? context.l10n.createSubjectPagesGoalLabel : context.l10n.createSubjectTimeGoalLabel} *",
                  ),
                  const Gap(4),
                  Text(
                    controller.isPageBased
                        ? context.l10n.createSubjectPagesGoalHelp
                        : context.l10n.createSubjectTimeGoalHelp,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                  const Gap(12),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (controller.isPageBased
                                  ? _pageGoalPresets
                                  : _timeGoalPresets)
                              .map(
                                (value) => _SelectableChip(
                                  label: controller.isPageBased
                                      ? context.l10n.metricPagesValue(
                                          value.toInt(),
                                        )
                                      : context.l10n.createSubjectHoursValue(
                                          value.toInt(),
                                        ),
                                  isSelected:
                                      controller.goal.value.trim() ==
                                      value.toString(),
                                  onTap: () => controller.setGoalPreset(value),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const Gap(12),
                  TextField(
                    controller: controller.goalController,
                    keyboardType: controller.isPageBased
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(decimal: true),
                    decoration: AppInputDecoration.withBorder(
                      tokens: context.colorTokens,
                      hintText: controller.isPageBased
                          ? context.l10n.goalPagesHint
                          : context.l10n.estimatedHoursGoalHint,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            _FormSection(
              title: context.l10n.createSubjectRoutineSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: context.l10n.createSubjectRestLabel),
                  const Gap(4),
                  Text(
                    context.l10n.createSubjectRestHelp,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                  const Gap(12),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CreateSubjectController.restMinutesOptions.map((
                        minutes,
                      ) {
                        return _SelectableChip(
                          label: context.l10n.restMinutesChip(minutes),
                          isSelected: minutes == controller.restMinutes.value,
                          onTap: () => controller.restMinutes.value = minutes,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            _FormSection(
              title: context.l10n.createSubjectPersonalizationSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _FieldLabel(
                        text: controller.isPageBased
                            ? context.l10n.bookThemeLabel
                            : context.l10n.colorLabel,
                      ),
                      const Gap(8),
                      _OptionalTag(),
                    ],
                  ),
                  const Gap(12),
                  Obx(
                    () => SubjectColorSelector(
                      selectedColor: controller.selectedColor.value,
                      onSelected: (color) =>
                          controller.selectedColor.value = color,
                      semanticLabelBuilder: (context, index) =>
                          context.l10n.createSubjectColorSemantic(index + 1),
                    ),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      _FieldLabel(text: context.l10n.iconLabel),
                      const Gap(8),
                      _OptionalTag(),
                    ],
                  ),
                  const Gap(12),
                  _IconSelector(controller: controller),
                  const Gap(20),
                  Row(
                    children: [
                      _FieldLabel(text: context.l10n.wallpaperLabel),
                      const Gap(8),
                      _OptionalTag(),
                    ],
                  ),
                  const Gap(12),
                  _WallpaperSelector(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPreview extends StatelessWidget {
  const _SubjectPreview({required this.controller});

  final CreateSubjectController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color color = controller.selectedColor.value;
    final IconData? icon = SubjectIcons.byName(
      controller.selectedIconName.value,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.createSubjectPreviewTitle,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  controller.previewName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(4),
                Text(
                  "${context.l10n.createSubjectPreviewGoal(controller.previewGoal(context))} · ${context.l10n.createSubjectPreviewRest(controller.restMinutes.value)}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(16),
        child,
      ],
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textStyles.bodySmall.copyWith(
      color: context.colorTokens.textBody,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _OptionalTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      context.l10n.optionalHint,
      style: context.textStyles.bodySmall.copyWith(
        color: context.colorTokens.primary,
        fontWeight: FontWeight.w800,
      ),
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
        return _SelectableChip(
          label: iconName,
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
      child: Row(
        children: List.generate(TimerWallpapers.values.length, (index) {
          final bool isSelected = index == controller.wallpaperIndex.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index == TimerWallpapers.values.length - 1 ? 0 : 10,
            ),
            child: GestureDetector(
              onTap: () => controller.wallpaperIndex.value = index,
              child: Container(
                width: 72,
                height: 92,
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

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? context.colorTokens.primary
                  : context.colorTokens.textHint,
            ),
            const Gap(8),
          ],
          Text(
            label,
            style: context.textStyles.bodySmall.copyWith(
              color: isSelected
                  ? context.colorTokens.primary
                  : context.colorTokens.textBody,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (isSelected) ...[
            const Gap(8),
            Icon(
              Icons.check_rounded,
              size: 14,
              color: context.colorTokens.primary,
            ),
          ],
        ],
      ),
    ),
  );
}
