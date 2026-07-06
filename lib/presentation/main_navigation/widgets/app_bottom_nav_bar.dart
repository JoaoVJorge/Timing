import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.selectedButton,
    required this.onTabTap,
    super.key,
  });

  final BottomNavButtonType selectedButton;
  final ValueChanged<BottomNavButtonType> onTabTap;

  Color iconColor(BuildContext context, {required bool isSelected}) =>
      isSelected
      ? context.colorTokens.primary
      : context.colorTokens.iconDisabled;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colorTokens.surface,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: BottomNavButtonType.values.map((button) {
            final bool isSelected = button == selectedButton;
            final Color color = iconColor(context, isSelected: isSelected);
            return Expanded(
              child: BounceTap(
                pressedScale: 0.85,
                onTap: () => onTabTap(button),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? context.colorTokens.primaryVeryLight
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(button.iconName, size: 24, color: color),
                      Text(
                        button.localizedLabel(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
