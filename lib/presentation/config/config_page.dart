import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/config/config_controller.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/avatar_presets.dart";

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Text("Settings", style: context.textStyles.titleFont),
          const Gap(24),
          Obx(
            () => BounceTap(
              pressedScale: 0.97,
              onTap: controller.onTapMyProfile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(gradient: context.colorTokens.primaryGradient, shape: BoxShape.circle),
                      child: Icon(AppAvatarPresets.byIndex(controller.avatarIconIndex.value), color: Colors.white),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.userName.value.isEmpty ? "My Profile" : controller.userName.value,
                            style: context.textStyles.extraBold20,
                          ),
                          if (controller.nickName.value.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcon("special_a", size: 12, color: context.colorTokens.textHint),
                                const Gap(4),
                                Text(
                                  controller.nickName.value,
                                  style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.colorTokens.iconDisabled),
                  ],
                ),
              ),
            ),
          ),
          const Gap(28),
          Text("Preferences", style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint)),
          const Gap(8),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: context.colorTokens.primaryVeryLight, shape: BoxShape.circle),
                    child: Center(child: AppIcon("moon", size: 18, color: context.colorTokens.primary)),
                  ),
                  const Gap(12),
                  Expanded(child: Text("Dark mode", style: context.textStyles.bodyLarge)),
                  Switch(
                    value: controller.isDarkMode.value,
                    onChanged: controller.onToggleDarkMode,
                    activeThumbColor: context.colorTokens.primary,
                    activeTrackColor: context.colorTokens.primaryPastel,
                  ),
                ],
              ),
            ),
          ),
          const Gap(28),
          Text("Support", style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint)),
          const Gap(8),
          BounceTap(
            pressedScale: 0.97,
            onTap: controller.onTapFaq,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.help_outline, color: context.colorTokens.primary),
                title: Text("FAQ", style: context.textStyles.bodyLarge),
                trailing: Icon(Icons.chevron_right, color: context.colorTokens.iconDisabled),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
