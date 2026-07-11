import ActivityKit
import Flutter
import Foundation

final class TimerLiveActivityPlugin: NSObject, FlutterPlugin {
  private static let channelName = "com.helpout/timer_live_activity"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(TimerLiveActivityPlugin(), channel: channel)
    if #available(iOS 17.2, *) {
      TimerLiveActivityManager.shared.observePushToStartToken()
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(nil)
      return
    }

    switch call.method {
    case "startOrUpdate":
      guard let arguments = call.arguments as? [String: Any],
            let subjectName = arguments["subjectName"] as? String,
            let colorHex = arguments["colorHex"] as? String,
            let remainingSeconds = arguments["remainingSeconds"] as? Int,
            let isRunning = arguments["isRunning"] as? Bool,
            let isResting = arguments["isResting"] as? Bool else {
        result(FlutterError(code: "bad_arguments", message: nil, details: nil))
        return
      }

      Task {
        await TimerLiveActivityManager.shared.startOrUpdate(
          subjectName: subjectName,
          colorHex: colorHex,
          remainingSeconds: remainingSeconds,
          isRunning: isRunning,
          isResting: isResting
        )
        result(nil)
      }
    case "consumePendingAction":
      let defaults = UserDefaults(suiteName: TimerActivitySharedStore.suiteName)
      let value = defaults?.dictionary(
        forKey: TimerActivitySharedStore.pendingActionKey
      )
      defaults?.removeObject(forKey: TimerActivitySharedStore.pendingActionKey)
      result(value)
    case "getPushToken":
      result(
        UserDefaults(suiteName: TimerActivitySharedStore.suiteName)?
          .string(forKey: TimerActivitySharedStore.pushTokenKey)
      )
    case "getPushToStartToken":
      result(
        UserDefaults(suiteName: TimerActivitySharedStore.suiteName)?
          .string(forKey: TimerActivitySharedStore.pushToStartTokenKey)
      )
    case "end":
      Task {
        await TimerLiveActivityManager.shared.end()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@available(iOS 16.2, *)
private final class TimerLiveActivityManager {
  static let shared = TimerLiveActivityManager()

  func startOrUpdate(
    subjectName: String,
    colorHex: String,
    remainingSeconds: Int,
    isRunning: Bool,
    isResting: Bool
  ) async {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

    let safeRemaining = max(0, remainingSeconds)
    let state = TimerActivityAttributes.ContentState(
      remainingSeconds: safeRemaining,
      endDate: Date().addingTimeInterval(TimeInterval(safeRemaining)),
      isRunning: isRunning,
      isResting: isResting
    )
    let content = ActivityContent(state: state, staleDate: state.endDate)

    if let activity = Activity<TimerActivityAttributes>.activities.first,
       activity.attributes.subjectName == subjectName,
       activity.attributes.colorHex == colorHex {
      await activity.update(content)
      return
    }

    for activity in Activity<TimerActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }

    do {
      let attributes = TimerActivityAttributes(
        sessionId: UUID().uuidString,
        subjectName: subjectName,
        colorHex: colorHex
      )
      let activity = try Activity.request(
        attributes: attributes,
        content: content,
        pushType: .token
      )
      observePushToken(for: activity)
    } catch {
      // A disabled entitlement or simulator limitation must not affect Flutter.
    }
  }

  func end() async {
    for activity in Activity<TimerActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }

  private func observePushToken(for activity: Activity<TimerActivityAttributes>) {
    Task {
      for await token in activity.pushTokenUpdates {
        let value = token.map { String(format: "%02x", $0) }.joined()
        UserDefaults(suiteName: TimerActivitySharedStore.suiteName)?
          .set(value, forKey: TimerActivitySharedStore.pushTokenKey)
      }
    }
  }

  @available(iOS 17.2, *)
  func observePushToStartToken() {
    Task {
      for await token in Activity<TimerActivityAttributes>.pushToStartTokenUpdates {
        let value = token.map { String(format: "%02x", $0) }.joined()
        UserDefaults(suiteName: TimerActivitySharedStore.suiteName)?
          .set(value, forKey: TimerActivitySharedStore.pushToStartTokenKey)
      }
    }
  }
}
