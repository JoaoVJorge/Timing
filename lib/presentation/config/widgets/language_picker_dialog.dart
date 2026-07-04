import "package:flutter/material.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/app_languages.dart";

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({required this.currentCode, super.key});

  final String currentCode;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.language),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: AppLanguages.values.map((language) {
        final bool isSelected = language.code == currentCode;
        return ListTile(
          onTap: () => appNavigator.back<String>(result: language.code),
          contentPadding: EdgeInsets.zero,
          title: Text(language.label, style: context.textStyles.bodyLarge),
          trailing: isSelected ? Icon(Icons.check, color: context.colorTokens.primary) : null,
        );
      }).toList(),
    ),
  );
}
