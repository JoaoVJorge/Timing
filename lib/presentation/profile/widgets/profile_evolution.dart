import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/functions/format_name.dart";

/// Narrative "Your progress" block that turns the raw stats into a short story
/// about the user's evolution instead of just listing numbers.
class ProfileEvolution extends StatelessWidget {
  const ProfileEvolution({required this.stats, super.key});

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = _buildLines(context);
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.profileEvolutionTitle,
            style: context.textStyles.extraBold20,
          ),
          const Gap(12),
          for (int index = 0; index < lines.length; index++) ...[
            if (index > 0) const Gap(8),
            _EvolutionLine(text: lines[index]),
          ],
        ],
      ),
    );
  }

  List<String> _buildLines(BuildContext context) {
    final List<String> lines = [];

    lines.add(
      context.l10n.profileEvolutionFocus(
        formatDurationLong(Duration(seconds: stats.totalFocusSeconds)),
      ),
    );

    if (stats.hasTopStudyingSubject) {
      lines.add(
        context.l10n.profileEvolutionTopSubject(
          capitalizeName(stats.topStudyingSubject!.name),
        ),
      );
    }

    final int remaining =
        stats.totalFocusGoalSeconds - stats.totalFocusSeconds;
    if (stats.totalFocusGoalSeconds > 0) {
      if (remaining > 0) {
        lines.add(
          context.l10n.profileEvolutionRemaining(
            formatDurationLong(Duration(seconds: remaining)),
          ),
        );
      } else {
        lines.add(context.l10n.profileEvolutionGoalReached);
      }
    }

    return lines;
  }
}

class _EvolutionLine extends StatelessWidget {
  const _EvolutionLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.primary,
          ),
        ),
      ),
      const Gap(12),
      Expanded(
        child: Text(text, style: context.textStyles.bodyMedium),
      ),
    ],
  );
}
