import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class IllustratedEmptyState extends StatelessWidget {
  const IllustratedEmptyState({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTapAction,
    required this.suggestionsTitle,
    required this.suggestions,
    super.key,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTapAction;
  final String suggestionsTitle;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 430),
    margin: const EdgeInsets.symmetric(horizontal: 6),
    padding: const EdgeInsets.fromLTRB(22, 48, 22, 30),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: context.colorTokens.primaryVeryLight.withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _EmptyOrnament(),
        const Gap(30),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textStyles.extraBold24.copyWith(
            color: context.colorTokens.textBody,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const Gap(14),
        Text(
          description,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyLarge.copyWith(
            color: context.colorTokens.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.42,
          ),
        ),
        const Gap(22),
        BounceTap(
          onTap: onTapAction,
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: context.colorTokens.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.colorTokens.primary.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              actionLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textPrimaryButton.copyWith(
                color: context.colorTokens.primaryForeground,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const Gap(24),
        const _StarDivider(),
        const Gap(16),
        Text(
          suggestionsTitle,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyLarge.copyWith(
            color: context.colorTokens.primary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final String suggestion in suggestions)
              _SuggestionChip(label: suggestion),
          ],
        ),
      ],
    ),
  );
}

class _EmptyOrnament extends StatelessWidget {
  const _EmptyOrnament();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _Line(color: context.colorTokens.primaryVeryLight),
      const Gap(16),
      for (int index = 0; index < 3; index++) ...[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryPastel.withValues(alpha: 0.56),
            shape: BoxShape.circle,
          ),
        ),
        if (index < 2) const Gap(10),
      ],
      const Gap(16),
      _Line(color: context.colorTokens.primaryVeryLight),
    ],
  );
}

class _StarDivider extends StatelessWidget {
  const _StarDivider();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _Line(color: context.colorTokens.primaryVeryLight),
      const Gap(20),
      Icon(
        Icons.auto_awesome_rounded,
        color: context.colorTokens.primary,
        size: 16,
      ),
      const Gap(20),
      _Line(color: context.colorTokens.primaryVeryLight),
    ],
  );
}

class _Line extends StatelessWidget {
  const _Line({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 86, height: 1, color: color);
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 38, minWidth: 88),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: context.colorTokens.primaryPastel.withValues(alpha: 0.42),
        width: 1.1,
      ),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.bodyMedium.copyWith(
        color: context.colorTokens.primary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
