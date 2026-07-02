import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class AppButton extends StatelessWidget {
  const AppButton({required this.icon, required this.onTap, this.size = 64, super.key});

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => GestureDetector(
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
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    ),
  );
}
