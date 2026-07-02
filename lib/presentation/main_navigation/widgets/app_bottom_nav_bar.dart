import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/main_navigation/enums/bottom_nav_button_type.dart";

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({required this.selectedButton, required this.onTabTap, super.key});

  final BottomNavButtonType selectedButton;
  final ValueChanged<BottomNavButtonType> onTabTap;

  Color iconColor(BuildContext context, {required bool isSelected}) =>
      isSelected ? context.colorTokens.primary : context.colorTokens.iconDisabled;

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
              child: GestureDetector(
                onTap: () => onTabTap(button),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(isSelected ? button.iconSelected : button.icon, color: color),
                    Text(button.label, style: context.textStyles.bodyTiny.copyWith(color: color)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
