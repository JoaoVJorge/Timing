import "package:flutter/services.dart";

class FocusGuardService {
  static const MethodChannel _channel = MethodChannel("help_out/focus_guard");

  Future<void> setKeepScreenOn(bool enabled) async {
    await _invoke("setKeepScreenOn", <String, Object?>{"enabled": enabled});
  }

  Future<void> bringAppToFront() async {
    await _invoke("bringAppToFront");
  }

  Future<void> _invoke(String method, [Map<String, Object?>? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
