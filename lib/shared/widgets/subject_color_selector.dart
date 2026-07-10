import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/subject_colors.dart";

class SubjectColorSelector extends StatelessWidget {
  const SubjectColorSelector({
    required this.selectedColor,
    required this.onSelected,
    this.semanticLabelBuilder,
    this.swatchSize = 40,
    this.spacing = 12,
    this.runSpacing = 12,
    super.key,
  });

  final Color selectedColor;
  final ValueChanged<Color> onSelected;
  final String Function(BuildContext context, int index)? semanticLabelBuilder;
  final double swatchSize;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: spacing,
    runSpacing: runSpacing,
    children: [
      for (int index = 0; index < SubjectColors.values.length; index++)
        _ColorSwatch(
          color: SubjectColors.values[index],
          isSelected:
              SubjectColors.values[index].toARGB32() ==
              selectedColor.toARGB32(),
          semanticLabel:
              semanticLabelBuilder?.call(context, index) ?? "Cor ${index + 1}",
          size: swatchSize,
          onTap: () => onSelected(SubjectColors.values[index]),
        ),
    ],
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.semanticLabel,
    required this.size,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final String semanticLabel;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    selected: isSelected,
    button: true,
    child: BounceTap(
      pressedScale: 0.9,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? context.colorTokens.textBody
                : Colors.white.withValues(alpha: 0.8),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: isSelected
              ? const Center(
                  child: AppIcon("check", size: 14, color: Colors.white),
                )
              : null,
        ),
      ),
    ),
  );
}
