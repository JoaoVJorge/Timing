import "package:flutter/foundation.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class AppLoggerService {
  void logAppError(String message, AppError error) {
    logError(message, error: error.message);
  }

  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint("[ERROR] $message | error: $error");
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  void logInfo(String message) {
    if (kDebugMode) {
      debugPrint("[INFO] $message");
    }
  }
}
