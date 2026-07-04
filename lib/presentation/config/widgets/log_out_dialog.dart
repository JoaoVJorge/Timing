import "package:flutter/material.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class LogOutDialog extends StatelessWidget {
  const LogOutDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.logOutDialogTitle),
    content: Text(context.l10n.logOutDialogContent),
    actions: [
      TextButton(onPressed: () => appNavigator.back<bool>(result: false), child: Text(context.l10n.cancelButton)),
      const SizedBox(width: 4),
      TextButton(
        onPressed: () => appNavigator.back<bool>(result: true),
        child: Text(context.l10n.logOutConfirmButton, style: TextStyle(color: context.colorTokens.error)),
      ),
    ],
  );
}
