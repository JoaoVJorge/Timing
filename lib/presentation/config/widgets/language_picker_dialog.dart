import "package:flutter/material.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/dialog_top_bar.dart";
import "package:help_out/theme/app_languages.dart";

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({required this.currentCode, super.key});

  final String currentCode;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: DialogTopBar(title: context.l10n.language),
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
                Expanded(
                  child: Text(
                    language.label,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: context.colorTokens.primary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, color: context.colorTokens.primary),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}
