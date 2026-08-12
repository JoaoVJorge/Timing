import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class GroupActivityLockBadge extends StatelessWidget {
  const GroupActivityLockBadge({
    this.size = 28,
    this.iconSize = 16,
    this.backgroundColor,
    this.iconColor,
    super.key,
  });

  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: backgroundColor ?? context.colorTokens.surfaceInnerLayer,
      shape: BoxShape.circle,
      border: Border.all(
        color: (iconColor ?? context.colorTokens.textHint).withValues(
          alpha: 0.22,
        ),
        width: 1,
      ),
    ),
    alignment: Alignment.center,
    child: Icon(
      Icons.lock_rounded,
      size: iconSize,
      color: iconColor ?? context.colorTokens.textHint,
    ),
  );
}
