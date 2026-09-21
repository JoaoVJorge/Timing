import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/focus/focus_guard_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel("timing/focus_guard");
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test("request does not imply screen pinning was confirmed", () async {
    final calls = <String>[];
    var nativeState = "inactive";
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return nativeState;
    });
    final guard = FocusGuardService();
    expect(await guard.requestScreenPinning(), FocusProtectionStatus.inactive);
    nativeState = "pinned";
    expect(await guard.getProtectionStatus(), FocusProtectionStatus.pinned);
    nativeState = "inactive";
    expect(await guard.stopScreenPinning(), FocusProtectionStatus.inactive);
    expect(calls, [
      "requestScreenPinning",
      "getProtectionStatus",
      "stopScreenPinning",
    ]);
  });

  test(
    "unsupported and rejected native calls are not reported as protected",
    () async {
      final guard = FocusGuardService();
      expect(
        await guard.getProtectionStatus(),
        FocusProtectionStatus.unavailable,
      );
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: "PINNING_UNAVAILABLE");
      });
      expect(
        await guard.requestScreenPinning(),
        FocusProtectionStatus.unavailable,
      );
    },
  );

  test("iOS release accurately reports Guided Access still active", () async {
    messenger.setMockMethodCallHandler(channel, (_) async => "guidedAccess");
    expect(
      await FocusGuardService().stopScreenPinning(),
      FocusProtectionStatus.guidedAccess,
    );
  });
}
