import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/progress/progress_controller.dart";
import "package:timing/shared/widgets/animated_segmented_tabs.dart";

class ProgressPeriodTabs extends StatelessWidget {
  const ProgressPeriodTabs({
    required this.selectedPeriod,
    required this.onSelectPeriod,
    super.key,
  });

  final ProgressPeriod selectedPeriod;
  final ValueChanged<ProgressPeriod> onSelectPeriod;

  @override
  Widget build(BuildContext context) => AnimatedSegmentedTabs(
    labels: [
      for (final ProgressPeriod period in ProgressPeriod.values)
        period.localizedLabel(context),
    ],
    selectedIndex: selectedPeriod.index,
    onSelectIndex: (index) => onSelectPeriod(ProgressPeriod.values[index]),
  );
}

extension ProgressPeriodLabelX on ProgressPeriod {
  String localizedLabel(BuildContext context) => switch (this) {
    ProgressPeriod.day => context.l10n.progressPeriodDay,
    ProgressPeriod.week => context.l10n.progressPeriodWeek,
    ProgressPeriod.month => context.l10n.progressPeriodMonth,
  };
}
