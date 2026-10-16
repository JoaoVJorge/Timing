import "package:flutter/foundation.dart";

/// Startup milestones, printed in every build mode, release included.
///
/// [AppLoggerService] is silent outside debug builds, so a device that never
/// leaves the splash screen had nothing to show for it. With these lines,
/// `adb logcat -s flutter` names the last step that started and, when one
/// failed, its error. Only step names and errors from the startup plumbing
/// (plugins, storage, routing) are printed, never user data.
abstract final class BootTrace {
  static final Stopwatch _clock = Stopwatch()..start();

  static void mark(String message) {
    debugPrint("[boot +${_clock.elapsedMilliseconds}ms] $message");
  }

  static void fail(String step, Object error, StackTrace stackTrace) {
    mark("$step FAILED: ${error.runtimeType}: $error");
    debugPrint(stackTrace.toString());
  }

  static Future<T> step<T>(String name, Future<T> Function() run) async {
    mark("$name...");
    try {
      final T result = await run();
      mark("$name ok");
      return result;
    } catch (error, stackTrace) {
      fail(name, error, stackTrace);
      rethrow;
    }
  }
}
