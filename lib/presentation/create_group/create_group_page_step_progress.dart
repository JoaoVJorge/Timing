part of "create_group_page.dart";

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      context.l10n.createGroupStepInformation,
      context.l10n.createGroupStepFriends,
      context.l10n.createGroupStepSummary,
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          for (int index = 0; index < labels.length; index++)
            Expanded(
              child: _StepSegment(
                number: index + 1,
                label: labels[index],
                isCompleted: index < currentStep,
                isCurrent: index == currentStep,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepSegment extends StatelessWidget {
  const _StepSegment({
    required this.number,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
  });

  final int number;
  final String label;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = isCompleted || isCurrent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 23,
            height: 23,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? context.colorTokens.primary
                  : context.colorTokens.surfaceInnerLayer,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: context.colorTokens.primaryForeground,
                  )
                : Text(
                    "$number",
                    style: context.textStyles.bodySmall.copyWith(
                      color: isCurrent
                          ? context.colorTokens.primaryForeground
                          : context.colorTokens.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const Gap(5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: isHighlighted
                    ? context.colorTokens.primary
                    : context.colorTokens.textHint,
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
