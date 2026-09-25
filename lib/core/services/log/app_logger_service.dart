import "package:flutter/foundation.dart";
import "package:timing/core/domain/errors/app_error.dart";

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

  /// Payload logging stays disabled because backend rows contain personal
  /// profile data, notes, schedules and activity history.
  void logRequest(String operation, [Object? payload]) {}

  void logResponse(String operation, Object? data) {}
}
