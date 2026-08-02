import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon_badge.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

typedef ProgressStat = ({IconData icon, String value, String label});

/// Complementary figures under the hero card. Focus time is deliberately not
/// one of them: it is the hero, and repeating it flattens the page.
class ProgressStatRow extends StatelessWidget {
  const ProgressStatRow({required this.stats, super.key});

  final List<ProgressStat> stats;

  @override
  // IntrinsicHeight, not a bare CrossAxisAlignment.stretch: this row lives in a
  // scroll view, where stretch would ask the tiles for an infinite height.
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < stats.length; index++) ...[
          if (index > 0) const Gap(AppSpacing.betweenRelated),
          Expanded(child: _StatTile(stat: stats[index])),
        ],
      ],
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final ProgressStat stat;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconBadge(icon: stat.icon, size: 32),
        const Gap(AppSpacing.betweenRelated),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.metricValue.copyWith(fontSize: 20),
        ),
        const Gap(4),
        Text(
          stat.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption.copyWith(fontSize: 12),
        ),
      ],
    ),
  );
}
