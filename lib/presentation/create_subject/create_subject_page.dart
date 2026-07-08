import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_subject/create_subject_controller.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class CreateSubjectPage extends StatelessWidget {
  const CreateSubjectPage({super.key});

  static const List<String> _musicSuggestions = [
    "Lo-fi",
    "Piano",
    "Classical",
    "Jazz",
    "Rain",
  ];

  @override
  Widget build(BuildContext context) {
    final CreateSubjectController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.addItemButton(
          controller.category.itemNoun(context),
        ),
        showBackButton: true,
      ),
      bottomBar: AppButton(
        label: context.l10n.addButton,
        onTap: controller.onSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.nameController,
              autofocus: true,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.itemNameHint(
                  controller.category.itemNoun(context),
                ),
              ),
            ),
            const Gap(20),
            _SectionLabel(text: context.l10n.iconLabel),
            const Gap(8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.iconSuggestions.map((iconName) {
                  final bool isSelected =
                      iconName == controller.selectedIconName.value;
                  return GestureDetector(
                    onTap: () => controller.selectedIconName.value = iconName,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorTokens.primaryVeryLight
                            : context.colorTokens.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? context.colorTokens.primary
                              : context.colorTokens.borderUnfocused,
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: Icon(
                        SubjectIcons.byName(iconName),
                        size: 22,
                        color: isSelected
                            ? context.colorTokens.primary
                            : context.colorTokens.textHint,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(20),
            _SectionLabel(
              text: controller.isPageBased
                  ? context.l10n.bookThemeLabel
                  : context.l10n.colorLabel,
            ),
            const Gap(8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SubjectColors.values.map((color) {
                  final bool isSelected =
                      color.toARGB32() ==
                      controller.selectedColor.value.toARGB32();
                  return GestureDetector(
                    onTap: () => controller.selectedColor.value = color,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: context.colorTokens.textBody,
                                width: 2,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: AppIcon(
                                "check",
                                size: 12,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(20),
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
            const Gap(20),
            _SectionLabel(text: context.l10n.restTimeLabel),
            const Gap(8),
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
            const Gap(20),
            _SectionLabel(text: context.l10n.musicSuggestionLabel),
            const Gap(8),
            TextField(
              controller: controller.musicController,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.musicSuggestionHint,
              ),
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _musicSuggestions
                  .map(
                    (suggestion) => _SelectableChip(
                      label: suggestion,
                      isSelected: false,
                      onTap: () => controller.musicController.text = suggestion,
                    ),
                  )
                  .toList(),
            ),
            const Gap(20),
            _SectionLabel(text: context.l10n.wallpaperLabel),
            const Gap(8),
            Obx(
              () => Row(
                children: List.generate(TimerWallpapers.values.length, (
                  index,
                ) {
                  final bool isSelected =
                      index == controller.wallpaperIndex.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == TimerWallpapers.values.length - 1 ? 0 : 8,
                    ),
                    child: GestureDetector(
                      onTap: () => controller.wallpaperIndex.value = index,
                      child: Container(
                        width: 44,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: TimerWallpapers.byIndex(index),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.colorTokens.primary
                                : context.colorTokens.borderUnfocused,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: AppIcon(
                                  "check",
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textStyles.bodySmall.copyWith(
      color: context.colorTokens.textHint,
    ),
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
    child: Container(
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
      child: Text(
        label,
        style: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.textBody,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
