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

  /// Backend traffic is logged as a whole by LoggingHttpClient, with the
  /// method, timing and both bodies of every request. These stay as no-ops so
  /// the call sites do not print each exchange a second time.
  void logRequest(String operation, [Object? payload]) {}

  void logResponse(String operation, Object? data) {}
}
