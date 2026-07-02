import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/config/config_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/theme/accent_presets.dart";

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
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Dark mode", style: context.textStyles.bodyLarge),
              value: controller.isDarkMode.value,
              onChanged: controller.onToggleDarkMode,
            ),
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
                return GestureDetector(
                  onTap: () => controller.onTapAccentColor(color),
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
        ],
      ),
    );
  }
}
