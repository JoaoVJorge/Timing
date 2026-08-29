import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/centered_wrap_grid.dart";
import "package:timing/theme/subject_colors.dart";

/// Rounded name field used at the top of every creation form: a tinted icon
/// box followed by a borderless text field.
class CreationNameField extends StatelessWidget {
  const CreationNameField({
    required this.controller,
    required this.hintText,
    required this.accent,
    required this.icon,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final Color accent;
  final Widget icon;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: context.creationCardDecoration(accent),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.65)),
          ),
          child: icon,
        ),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: context.colorTokens.textHint.withValues(alpha: 0.62),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Surface card that groups a [CreationSectionHeader] with its body.
class CreationConfigCard extends StatelessWidget {
  const CreationConfigCard({
    required this.accent,
    required this.header,
    required this.child,
    super.key,
  });

  final Color accent;
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: context.creationCardDecoration(accent),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, const Gap(12), child],
    ),
  );
}

class CreationSectionHeader extends StatelessWidget {
  const CreationSectionHeader({
    required this.icon,
    required this.label,
    required this.accent,
    this.description,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final String? description;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, size: 24, color: accent),
      const Gap(10),
      Expanded(
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colorTokens.textBody,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      if (description != null) ...[
        const Gap(8),
        Tooltip(
          message: description!,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 5),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.colorTokens.dialogSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorTokens.divider),
            boxShadow: [
              BoxShadow(
                color: context.colorTokens.surfaceShadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          textStyle: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.dialogText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon("info", size: 14, color: accent),
          ),
        ),
      ],
    ],
  );
}

class CreationSelectableChip extends StatelessWidget {
  const CreationSelectableChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? accent : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected ? accent : context.colorTokens.borderUnfocused,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: isSelected
                ? context.colorTokens.white
                : context.colorTokens.textBody,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
}

class CreationOptionCard extends StatelessWidget {
  const CreationOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.optionColor,
    required this.isSelected,
    required this.onTap,
    this.iconSize = 30,
    this.iconBoxSize = 48,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color optionColor;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double iconBoxSize;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? context.colorTokens.surface.withValues(alpha: 0.82)
        : context.colorTokens.surface;
    final Color borderColor = isSelected
        ? optionColor.withValues(alpha: 0.68)
        : context.colorTokens.borderUnfocused.withValues(alpha: 0.7);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: optionColor.withValues(alpha: isDark ? 0.16 : 0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: optionColor.withValues(alpha: isDark ? 0.15 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: optionColor.withValues(alpha: isSelected ? 0.72 : 0.2),
                ),
              ),
              child: Icon(icon, color: optionColor, size: iconSize),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: optionColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    description,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textBody,
                      fontWeight: FontWeight.w700,
                      height: 1.24,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? optionColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? optionColor
                      : context.colorTokens.textHint.withValues(alpha: 0.55),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorTokens.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class CreationColorChoice extends StatelessWidget {
  const CreationColorChoice({
    required this.color,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color.withValues(alpha: 0.38) : color,
        border: Border.all(color: color, width: isSelected ? 2 : 0),
      ),
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Center(
                child: AppIcon("check", size: 10, color: Colors.white),
              ),
            )
          : null,
    ),
  );
}

/// Full "pick a color" card: a header plus the row of [SubjectColors].
class CreationColorSection extends StatelessWidget {
  const CreationColorSection({
    required this.accent,
    required this.label,
    required this.onSelect,
    this.extraColors = const [],
    this.includePastelColors = false,
    super.key,
  });

  final Color accent;
  final String label;
  final ValueChanged<Color> onSelect;
  final List<Color> extraColors;
  final bool includePastelColors;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = _dedupedColors([
      ...extraColors.map(SubjectColors.normalize),
      ...SubjectColors.values,
      if (includePastelColors) ...SubjectColors.darkValues,
    ]);

    return CreationConfigCard(
      accent: accent,
      header: CreationSectionHeader(
        icon: Icons.palette_outlined,
        label: label,
        accent: accent,
      ),
      child: CenteredBalancedRows(
        spacing: 10,
        runSpacing: 10,
        children: colors
            .map(
              (color) => CreationColorChoice(
                color: color,
                isSelected: color.toARGB32() == accent.toARGB32(),
                onTap: () => onSelect(color),
              ),
            )
            .toList(),
      ),
    );
  }

  List<Color> _dedupedColors(List<Color> colors) {
    final Set<int> seen = <int>{};
    return [
      for (final Color color in colors)
        if (seen.add(color.toARGB32())) color,
    ];
  }
}

/// Gradient pill submit button pinned to the bottom of a creation form.
class CreationSubmitButton extends StatelessWidget {
  const CreationSubmitButton({
    required this.label,
    required this.accent,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: !isEnabled || isLoading,
    child: BounceTap(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: !isEnabled && !isLoading ? 0.62 : 1,
        child: Container(
          width: double.infinity,
          height: 60,
          padding: isLoading
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 56, right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent,
                Color.lerp(accent, context.colorTokens.white, 0.1) ?? accent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.2,
                      strokeCap: StrokeCap.round,
                      color: context.colorTokens.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colorTokens.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: context.colorTokens.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: accent,
                        size: 28,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}
