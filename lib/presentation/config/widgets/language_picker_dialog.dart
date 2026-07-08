import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/dialog_top_bar.dart";
import "package:help_out/theme/app_languages.dart";

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({required this.currentCode, super.key});

  final String currentCode;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: DialogTopBar(title: context.l10n.chooseLanguageTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: AppLanguages.values.map((language) {
        final bool isSelected = language.code == currentCode;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => appNavigator.back<String>(result: language.code),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: context.colorTokens.primary,
                        )
                      : null,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    language.label,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: isSelected
                          ? context.colorTokens.primary
                          : context.colorTokens.textBody,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
    actions: [
      TextButton(
        onPressed: () => appNavigator.back<String>(),
        child: Text(context.l10n.cancelButton),
      ),
    ],
  );
}
