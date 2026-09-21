import "package:flutter/services.dart";

enum FocusProtectionStatus { unavailable, inactive, pinned, guidedAccess }

class FocusGuardService {
  static const MethodChannel _channel = MethodChannel("timing/focus_guard");

  Future<void> setKeepScreenOn(bool enabled) async {
    await _invoke("setKeepScreenOn", <String, Object?>{"enabled": enabled});
  }

  Future<void> setImmersiveMode(bool enabled) async {
    await _invoke("setImmersiveMode", <String, Object?>{"enabled": enabled});
  }

  Future<FocusProtectionStatus> getProtectionStatus() =>
      _readStatus("getProtectionStatus");

  /// Android presents its own consent dialog. A request is not confirmation
  /// that the screen is pinned; callers must continue checking actual state.
  Future<FocusProtectionStatus> requestScreenPinning() =>
      _readStatus("requestScreenPinning");

  Future<FocusProtectionStatus> stopScreenPinning() =>
      _readStatus("stopScreenPinning");

  Future<FocusProtectionStatus> _readStatus(String method) async {
    try {
      final value = await _channel.invokeMethod<String>(method);
      return switch (value) {
        "inactive" => FocusProtectionStatus.inactive,
        "pinned" => FocusProtectionStatus.pinned,
        "guidedAccess" => FocusProtectionStatus.guidedAccess,
        _ => FocusProtectionStatus.unavailable,
      };
    } on PlatformException {
      return FocusProtectionStatus.unavailable;
    } on MissingPluginException {
      return FocusProtectionStatus.unavailable;
    }
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
