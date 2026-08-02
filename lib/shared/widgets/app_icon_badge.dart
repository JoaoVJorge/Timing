import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

/// Circular icon holder. Decorative badges stay neutral so the accent colour
/// keeps meaning something; pass [color] only when the icon carries state.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    required this.icon,
    this.color,
    this.size = 40,
    this.iconSize,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? context.colorTokens.textHint;
    final double effectiveIconSize = iconSize ?? size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color == null
            ? context.colorTokens.surfaceInnerLayer.withValues(
                alpha: context.isDarkMode ? 0.55 : 0.6,
              )
            : effectiveColor.withValues(
                alpha: context.isDarkMode ? 0.18 : 0.12,
              ),
      ),
      child: Icon(icon, size: effectiveIconSize, color: effectiveColor),
    );
  }
}
