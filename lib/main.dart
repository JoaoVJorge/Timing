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
      final Object exception = details.exception;
      if (exception is AppError) {
        _showError(exception);
      }
    };
    await AppBindings().dependencies();
    runApp(const AppWidget());
  }, (error, stack) => _showError(error));
}

void _showError(Object error) {
  if (!Get.isRegistered<AppNavigator>()) {
    return;
  }
  final AppNavigator navigator = Get.find<AppNavigator>();
  if (error is AppError) {
    navigator.showErrorSnackBar(error.message);
    return;
  }
  navigator.showErrorSnackBar();
}
