import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon_badge.dart";
import "package:help_out/theme/app_spacing.dart";

typedef ProgressStat = ({
  IconData icon,
  String value,
  String label,
  Color accent,
});

/// Compact 2x2 progress summary for the selected period.
class ProgressStatRow extends StatelessWidget {
  const ProgressStatRow({required this.stats, super.key});

  final List<ProgressStat> stats;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = AppSpacing.betweenRelated;
      final double tileWidth = (constraints.maxWidth - spacing) / 2;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final ProgressStat stat in stats)
            SizedBox(
              width: tileWidth,
              child: _StatTile(stat: stat),
            ),
        ],
      );
    },
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final ProgressStat stat;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconBadge(icon: stat.icon, color: stat.accent, size: 38),
          const Gap(8),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.metricValue.copyWith(
              color: isDarkMode
                  ? Color.lerp(stat.accent, Colors.white, 0.22)
                  : context.colorTokens.textBody,
              fontSize: 24,
            ),
          ),
          const Gap(4),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
