import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_task/create_task_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/floating_primary_button.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";

class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateTaskController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.createTaskTitle,
        showBackButton: true,
      ),
      bottomBar: FloatingPrimaryButton(
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
                hintText: context.l10n.taskNameHint,
              ),
            ),
            const Gap(20),
            Text(
              context.l10n.colorLabel,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
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
            Text(
              context.l10n.targetDaysLabel,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CreateTaskController.targetDaysOptions.map((days) {
                  final bool isSelected = days == controller.targetDays.value;
                  return GestureDetector(
                    onTap: () => controller.onSelectTargetDays(days),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                        context.l10n.targetDaysChip(days),
                        style: context.textStyles.bodySmall.copyWith(
                          color: isSelected
                              ? context.colorTokens.primary
                              : context.colorTokens.textBody,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(12),
            TextField(
              controller: controller.customDaysController,
              keyboardType: TextInputType.number,
              onChanged: controller.onCustomDaysChanged,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.targetDaysHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
