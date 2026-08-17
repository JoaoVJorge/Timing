import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/config/widgets/language_picker_dialog.dart";
import "package:timing/presentation/config/widgets/log_out_dialog.dart";

Future<String?> showLanguagePickerDialog({required String? currentCode}) {
  final BuildContext context = Get.context!;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colorTokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => LanguagePickerDialog(currentCode: currentCode),
  );
}

Future<bool?> showLogOutDialog() =>
    appNavigator.dialog<bool>(child: const LogOutDialog());
