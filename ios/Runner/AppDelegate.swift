import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "TimerLiveActivityPlugin"
    ) {
      TimerLiveActivityPlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "FocusGuardPlugin"
    ) {
      let channel = FlutterMethodChannel(
        name: "help_out/focus_guard",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "setKeepScreenOn":
          let arguments = call.arguments as? [String: Any]
          UIApplication.shared.isIdleTimerDisabled =
            arguments?["enabled"] as? Bool ?? false
          result(nil)
        case "bringAppToFront":
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
