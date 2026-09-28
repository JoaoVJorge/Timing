import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_widget.dart";
import "package:timing/app/bindings/app_bindings.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/log/app_logger_service.dart";

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
  }, _showError);
}

void _showError(Object error, [StackTrace? stackTrace]) {
  if (stackTrace != null && Get.isRegistered<AppLoggerService>()) {
    Get.find<AppLoggerService>().logError(
      "Unhandled error",
      error: error,
      stackTrace: stackTrace,
    );
  }
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
