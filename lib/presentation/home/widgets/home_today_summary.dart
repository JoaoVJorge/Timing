import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

/// Row of compact "today" metric tiles (focus, goals, pages, sessions).
class HomeTodaySummary extends StatelessWidget {
  const HomeTodaySummary({required this.items, super.key});

  final List<({String value, String label})> items;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int i = 0; i < items.length; i++) ...[
        if (i > 0) const Gap(12),
        Expanded(
          child: _SummaryTile(
            value: items[i].value,
            label: items[i].label,
          ),
        ),
      ],
    ],
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.black20,
        ),
        const Gap(4),
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
