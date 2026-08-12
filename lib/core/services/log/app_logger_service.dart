import "package:flutter/foundation.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class AppLoggerService {
  /// Long string values (e.g. base64 photo blobs) are trimmed to this many
  /// characters so a logged backend response stays readable.
  static const int _maxStringLength = 120;

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

  /// Logs a payload sent to the backend. Debug builds only.
  void logRequest(String operation, [Object? payload]) {
    if (kDebugMode) {
      final String suffix = payload == null
          ? ""
          : " | payload: ${_sanitize(payload)}";
      debugPrint("[REQUEST][$operation]$suffix");
    }
  }

  /// Logs the raw values received from the backend so they can be inspected
  /// while debugging. Overly long string values are truncated and it is a
  /// no-op outside debug builds.
  void logResponse(String operation, Object? data) {
    if (kDebugMode) {
      debugPrint("[RESPONSE][$operation] | data: ${_sanitize(data)}");
    }
  }

  /// Recursively copies [value], shortening any string longer than
  /// [_maxStringLength] so structure is preserved while noisy blobs are cut.
  Object? _sanitize(Object? value) {
    if (value is String) {
      if (value.length <= _maxStringLength) {
        return value;
      }
      return "${value.substring(0, _maxStringLength)}… (${value.length} chars)";
    }
    if (value is Map) {
      return {
        for (final MapEntry<dynamic, dynamic> entry in value.entries)
          entry.key.toString(): _sanitize(entry.value),
      };
    }
    if (value is Iterable) {
      return value.map(_sanitize).toList();
    }
    return value;
  }
}
