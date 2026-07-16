import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/subject_colors.dart";

/// Rounded name field used at the top of every creation form: a tinted icon
/// box followed by a borderless text field.
class CreationNameField extends StatelessWidget {
  const CreationNameField({
    required this.controller,
    required this.hintText,
    required this.accent,
    required this.icon,
    this.autofocus = true,
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
    super.key,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 24, color: accent),
      const Gap(10),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colorTokens.textBody,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
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
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: accent.withValues(alpha: 0.24),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
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
        color: isSelected ? color.withValues(alpha: 0.2) : color,
        border: Border.all(color: color, width: isSelected ? 2 : 0),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
        ],
      ),
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Center(
                child: AppIcon("check", size: 14, color: Colors.white),
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
    super.key,
  });

  final Color accent;
  final String label;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) => CreationConfigCard(
    accent: accent,
    header: CreationSectionHeader(
      icon: Icons.palette_outlined,
      label: label,
      accent: accent,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: SubjectColors.values
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
        opacity: !isEnabled
            ? 0.62
            : isLoading
            ? 0.7
            : 1,
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.only(left: 56, right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent,
                Color.lerp(accent, context.colorTokens.white, 0.22) ?? accent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
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
