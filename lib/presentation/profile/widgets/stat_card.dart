import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class StatCard extends StatelessWidget {
  const StatCard({required this.icon, required this.label, required this.value, super.key});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [BoxShadow(color: context.colorTokens.surfaceShadow, blurRadius: 12, offset: const Offset(0, 6))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: context.colorTokens.primaryVeryLight, shape: BoxShape.circle),
          child: Icon(icon, color: context.colorTokens.primary, size: 20),
        ),
        const Gap(12),
        Text(value, style: context.textStyles.black20, maxLines: 1, overflow: TextOverflow.ellipsis),
        const Gap(2),
        Text(label, style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint)),
      ],
    ),
  );
}
