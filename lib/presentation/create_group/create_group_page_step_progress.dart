part of "create_group_page.dart";

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      context.l10n.createGroupStepInformation,
      context.l10n.createGroupStepActivity,
      context.l10n.createGroupStepFriends,
      context.l10n.createGroupStepSummary,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double stepWidth = constraints.maxWidth / labels.length;

        return SizedBox(
          height: 62,
          child: Stack(
            children: [
              for (int index = 0; index < labels.length - 1; index++)
                Positioned(
                  top: 16,
                  left: stepWidth * (index + 0.5) + 22,
                  width: stepWidth - 44,
                  child: Container(
                    height: 1,
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
                        isActive: index <= currentStep,
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
    required this.isActive,
  });

  final int number;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? context.colorTokens.primary
        : context.colorTokens.borderUnfocused;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            "$number",
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Gap(8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: isActive
                ? context.colorTokens.primary
                : context.colorTokens.textHint,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
