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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double stepWidth = constraints.maxWidth / labels.length;
        return SizedBox(
          height: 76,
          child: Stack(
            children: [
              for (int index = 0; index < labels.length - 1; index++)
                Positioned(
                  top: 17,
                  left: stepWidth * (index + 0.5) + 26,
                  width: stepWidth - 52,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    color: index < currentStep
                        ? context.colorTokens.primary
                        : context.colorTokens.borderUnfocused,
                  ),
                ),
              Row(
                children: [
                  for (int index = 0; index < labels.length; index++)
                    Expanded(
                      child: _StepMarker(
                        number: index + 1,
                        label: labels[index],
                        isCompleted: index < currentStep,
                        isCurrent: index == currentStep,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({
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
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
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
                  size: 20,
                  color: context.colorTokens.primaryForeground,
                )
              : Text(
                  "$number",
                  style: context.textStyles.bodyMedium.copyWith(
                    color: isCurrent
                        ? context.colorTokens.primaryForeground
                        : context.colorTokens.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const Gap(8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: isHighlighted
                ? context.colorTokens.primary
                : context.colorTokens.textHint,
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
