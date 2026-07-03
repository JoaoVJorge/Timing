import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/edit_profile/edit_profile_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/accent_presets.dart";
import "package:help_out/theme/avatar_presets.dart";
import "package:help_out/theme/decoration.dart";

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final EditProfileController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            Row(
              children: [
                IconButton(onPressed: appNavigator.back, icon: Icon(Icons.arrow_back, color: context.colorTokens.textBody)),
                Text("My Profile", style: context.textStyles.titleFont),
              ],
            ),
            const Gap(16),
            Center(
              child: Obx(
                () => Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(gradient: context.colorTokens.primaryGradient, shape: BoxShape.circle),
                  child: Icon(
                    AppAvatarPresets.byIndex(controller.avatarIconIndex.value),
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
            const Gap(24),
            Text("Avatar", style: context.textStyles.bodyLarge),
            const Gap(12),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(AppAvatarPresets.values.length, (index) {
                  final bool isSelected = index == controller.avatarIconIndex.value;
                  return BounceTap(
                    onTap: () => controller.onSelectAvatarIcon(index),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? context.colorTokens.primaryVeryLight : context.colorTokens.surfaceInnerLayer,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: context.colorTokens.primary, width: 2) : null,
                      ),
                      child: Icon(
                        AppAvatarPresets.values[index],
                        color: isSelected ? context.colorTokens.primary : context.colorTokens.textHint,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Gap(24),
            Text("Name", style: context.textStyles.bodyLarge),
            const Gap(8),
            TextField(
              controller: controller.nameController,
              onChanged: controller.onNameChanged,
              decoration: AppInputDecoration.withBorder(tokens: context.colorTokens, hintText: "Your name"),
            ),
            const Gap(20),
            Text("Nickname", style: context.textStyles.bodyLarge),
            const Gap(8),
            TextField(
              controller: controller.nickNameController,
              onChanged: controller.onNickNameChanged,
              decoration: AppInputDecoration.withBorder(tokens: context.colorTokens, hintText: "What friends call you"),
            ),
            const Gap(24),
            Text("Theme color", style: context.textStyles.bodyLarge),
            const Gap(12),
            Obx(
              () => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: AppAccentPresets.values.map((color) {
                  final bool isSelected = controller.accentColor.value.toARGB32() == color.toARGB32();
                  return BounceTap(
                    onTap: () => controller.onSelectAccentColor(color),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: context.colorTokens.textBody, width: 3) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}
