import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/app_languages.dart";

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({required this.currentCode, super.key});

  final String currentCode;

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    backgroundColor: context.colorTokens.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: context.colorTokens.dialogSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.primaryVeryLight,
              border: Border.all(
                color: context.colorTokens.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Icon(
              Icons.language_rounded,
              color: context.colorTokens.primary,
              size: 34,
            ),
          ),
          const Gap(18),
          Text(
            context.l10n.chooseLanguageTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorTokens.dialogText,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const Gap(22),
          for (int index = 0; index < AppLanguages.values.length; index++) ...[
            if (index > 0) const Gap(10),
            _LanguageOption(
              language: AppLanguages.values[index],
              isSelected: AppLanguages.values[index].code == currentCode,
              onTap: () => appNavigator.back<String>(
                result: AppLanguages.values[index].code,
              ),
            ),
          ],
          const Gap(20),
          Divider(color: context.colorTokens.divider),
          const Gap(18),
          _DialogButton(
            label: context.l10n.cancelButton,
            onTap: () => appNavigator.back<String>(),
          ),
        ],
      ),
    ),
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary.withValues(alpha: 0.55)
              : context.colorTokens.borderUnfocused.withValues(alpha: 0.65),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(language.flag, style: const TextStyle(fontSize: 24)),
          const Gap(12),
          Expanded(
            child: Text(
              language.label,
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

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorTokens.borderFocused),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.colorTokens.dialogTextMuted,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
