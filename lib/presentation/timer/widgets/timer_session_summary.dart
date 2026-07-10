import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";

class TimerSessionSummary extends StatelessWidget {
  const TimerSessionSummary({
    required this.subjectName,
    required this.sessionSeconds,
    required this.totalSeconds,
    required this.onBackTap,
    super.key,
  });

  final String subjectName;
  final int sessionSeconds;
  final int totalSeconds;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: context.colorTokens.black.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: context.colorTokens.white.withValues(alpha: 0.16),
      ),
    ),
    child: Column(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 54,
          color: context.colorTokens.success,
        ),
        const Gap(12),
        Text(
          context.l10n.timerSessionSavedTitle,
          textAlign: TextAlign.center,
          style: context.textStyles.titleFont.copyWith(
            color: context.colorTokens.white,
          ),
        ),
        const Gap(8),
        Text(
          context.l10n.timerSessionSavedDescription,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.white.withValues(alpha: 0.72),
          ),
        ),
        const Gap(20),
        _SummaryRow(
          label: subjectName,
          value: context.l10n.timerFocusedValue(
            formatDurationLong(Duration(seconds: sessionSeconds)),
          ),
        ),
        const Gap(12),
        _SummaryRow(
          label: context.l10n.timerAccumulatedTotalLabel,
          value: formatDurationLong(Duration(seconds: totalSeconds)),
        ),
        const Gap(24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onBackTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorTokens.white,
              foregroundColor: context.colorTokens.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(context.l10n.timerBackToSubjectsButton),
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: context.colorTokens.white.withValues(alpha: 0.1),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.white.withValues(alpha: 0.72),
            ),
          ),
        ),
        const Gap(12),
        Text(
          value,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
