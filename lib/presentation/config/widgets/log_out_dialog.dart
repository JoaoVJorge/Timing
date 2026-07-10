import "package:flutter/material.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/dialog_top_bar.dart";

class LogOutDialog extends StatelessWidget {
  const LogOutDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: DialogTopBar(title: context.l10n.logOutDialogTitle),
    content: Text(
      context.l10n.logOutDialogContent,
      style: context.textStyles.bodyMedium.copyWith(
        color: context.colorTokens.textBody,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => appNavigator.back<bool>(result: false),
        child: Text(context.l10n.cancelButton),
      ),
      const SizedBox(width: 4),
      FilledButton(
        onPressed: () => appNavigator.back<bool>(result: true),
        style: FilledButton.styleFrom(
          backgroundColor: context.colorTokens.error,
          foregroundColor: Colors.white,
        ),
        child: Text(context.l10n.logOutConfirmButton),
      ),
    ],
  );
}
