import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_languages.dart";

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({required this.currentCode, super.key});

  final String? currentCode;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: 0.82,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 54,
                height: 6,
                decoration: BoxDecoration(
                  color: context.colorTokens.borderUnfocused,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Gap(26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LanguageHeroBadge(),
                const Gap(18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.chooseLanguageTitle,
                        style: context.textStyles.extraBold24,
                      ),
                      const Gap(8),
                      Text(
                        context.l10n.appLanguageSubtitle,
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colorTokens.textHint,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(28),
            Text(
              context.l10n.language,
              style: context.textStyles.sectionTitle.copyWith(
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (
                    int index = 0;
                    index < AppLanguages.values.length;
                    index++
                  ) ...[
                    if (index > 0) const Gap(10),
                    _LanguageOption(
                      flag: AppLanguages.values[index].flag,
                      label: AppLanguages.values[index].label,
                      isSelected:
                          AppLanguages.values[index].code == currentCode,
                      onTap: () => appNavigator.back<String>(
                        result: AppLanguages.values[index].code,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LanguageHeroBadge extends StatelessWidget {
  const _LanguageHeroBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.primaryVeryLight,
        border: Border.all(color: tokens.primary.withValues(alpha: 0.16)),
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.primary.withValues(alpha: 0.10),
          ),
          child: Icon(Icons.language_rounded, color: tokens.primary, size: 38),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused.withValues(alpha: 0.65),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.primary.withValues(alpha: 0.12),
            ),
            child: Text(flag, style: const TextStyle(fontSize: 24)),
          ),
          const Gap(14),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                color: isSelected
                    ? context.colorTokens.primary
                    : context.colorTokens.dialogText,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          const Gap(12),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: isSelected ? 1 : 0,
            child: Icon(
              Icons.check_circle_rounded,
              color: context.colorTokens.primary,
              size: 22,
            ),
          ),
        ],
      ),
    ),
  );
}
