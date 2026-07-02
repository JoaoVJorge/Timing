import "package:flutter/foundation.dart";

class AppLoggerService {
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
