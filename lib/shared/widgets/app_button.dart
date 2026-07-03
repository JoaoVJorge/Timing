import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class AppButton extends StatelessWidget {
  const AppButton({this.icon, this.svgName, required this.onTap, this.size = 64, super.key})
    : assert(icon != null || svgName != null, "Provide either icon or svgName");

  final IconData? icon;
  final String? svgName;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: context.colorTokens.primaryGradient,
        boxShadow: [
          BoxShadow(color: context.colorTokens.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Center(
        child: svgName != null
            ? AppIcon(svgName!, size: size * 0.45, color: Colors.white)
            : Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    ),
  );
}
