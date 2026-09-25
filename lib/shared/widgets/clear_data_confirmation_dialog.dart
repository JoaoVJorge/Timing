import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_confirmation_dialog.dart";

typedef ClearDataConfirmationCallback =
    Future<bool> Function({
      required String itemName,
      required bool isGoal,
      required bool isFromGroup,
    });

/// Asks before wiping the user's own progress on an activity or goal. The item
/// itself stays; only what the user did on it goes. For a group item the
/// message also says that the user's share of the group ranking goes with it.
Future<bool> showClearDataConfirmationDialog({
  required String itemName,
  required bool isGoal,
  required bool isFromGroup,
}) {
  final BuildContext? context = Get.context;
  if (context == null) {
    return Future<bool>.value(false);
  }
  final String message = isGoal
      ? context.l10n.clearGoalDataMessage(itemName)
      : context.l10n.clearActivityDataMessage(itemName);

  return showAppConfirmationDialog(
    title: context.l10n.clearDataDialogTitle,
    message: isFromGroup
        ? "$message\n\n${context.l10n.clearDataGroupNote}"
        : message,
    cancelLabel: context.l10n.cancelButton,
    confirmLabel: context.l10n.clearDataButtonLabel,
    icon: Icons.delete_sweep_rounded,
    isDestructive: true,
  );
}
