import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

/// Row of compact "today" metric tiles (focus, goals, pages, sessions).
class HomeTodaySummary extends StatelessWidget {
  const HomeTodaySummary({required this.items, super.key});

  final List<({IconData icon, String value, String label})> items;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int i = 0; i < items.length; i++) ...[
        if (i > 0) const Gap(12),
        Expanded(
          child: _SummaryTile(
            icon: items[i].icon,
            value: items[i].value,
            label: items[i].label,
          ),
        ),
      ],
    ],
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
    ),
    child: Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.primary.withValues(
              alpha: context.isDarkMode ? 0.16 : 0.12,
            ),
          ),
          child: Icon(icon, size: 17, color: context.colorTokens.primary),
        ),
        const Gap(10),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.black20.copyWith(
            color: context.colorTokens.primary,
            fontSize: 22,
          ),
        ),
        const Gap(2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
      ],
    ),
  );
}
