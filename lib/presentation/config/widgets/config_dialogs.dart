import "package:help_out/app/app_navigator.dart";
import "package:help_out/presentation/config/widgets/language_picker_dialog.dart";
import "package:help_out/presentation/config/widgets/log_out_dialog.dart";

Future<String?> showLanguagePickerDialog({required String currentCode}) =>
    appNavigator.dialog<String>(
      child: LanguagePickerDialog(currentCode: currentCode),
    );

Future<bool?> showLogOutDialog() =>
    appNavigator.dialog<bool>(child: const LogOutDialog());
