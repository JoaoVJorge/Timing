import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class AnimatedSegmentedTabs extends StatelessWidget {
  const AnimatedSegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelectIndex,
    this.onSwipe,
    this.height = 56,
    this.padding = const EdgeInsets.all(5),
    this.borderRadius = 16,
    this.indicatorBorderRadius = 14,
    super.key,
  }) : assert(labels.length > 0);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final ValueChanged<int>? onSwipe;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double indicatorBorderRadius;

  @override
  Widget build(BuildContext context) {
    final int clampedIndex = selectedIndex.clamp(0, labels.length - 1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: onSwipe == null
          ? null
          : (details) {
              final double velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() < 180) {
                return;
              }
              onSwipe!(velocity < 0 ? 1 : -1);
            },
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: _indicatorAlignment(clampedIndex, labels.length),
              child: FractionallySizedBox(
                widthFactor: 1 / labels.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: context.colorTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(indicatorBorderRadius),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  for (int index = 0; index < labels.length; index++)
                    _AnimatedSegmentedTab(
                      label: labels[index],
                      isSelected: clampedIndex == index,
                      onTap: () => onSelectIndex(index),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSegmentedTab extends StatelessWidget {
  const _AnimatedSegmentedTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      selected: isSelected,
      child: BounceTap(
        onTap: onTap,
        pressedScale: 0.98,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium.copyWith(
                color: isSelected
                    ? context.colorTokens.primaryForeground
                    : context.colorTokens.textBody,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Alignment _indicatorAlignment(int selectedIndex, int itemCount) {
  if (itemCount <= 1) {
    return Alignment.center;
  }
  return Alignment(-1 + (2 * selectedIndex / (itemCount - 1)), 0);
}
