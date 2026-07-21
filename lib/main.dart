import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_widget.dart";
import "package:help_out/app/bindings/app_bindings.dart";
import "package:help_out/core/domain/errors/app_error.dart";

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _showUnhandledError(details.exception);
    };
    await AppBindings().dependencies();
    runApp(const AppWidget());
  }, (error, stack) => _showUnhandledError(error));
}

void _showUnhandledError(Object error) {
  if (!Get.isRegistered<AppNavigator>()) {
    return;
  }
  final String message = error is AppError ? error.message : error.toString();
  Get.find<AppNavigator>().showErrorSnackBar(message);
}
