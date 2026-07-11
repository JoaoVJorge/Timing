import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct TimerActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var remainingSeconds: Int
    var endDate: Date
    var isRunning: Bool
    var isResting: Bool

    var currentRemainingSeconds: Int {
      guard isRunning else { return max(0, remainingSeconds) }
      return max(0, Int(endDate.timeIntervalSinceNow.rounded(.up)))
    }
  }

  let sessionId: String
  let subjectName: String
  let colorHex: String
}

enum TimerActivitySharedStore {
  static let suiteName = "group.com.example.helpOut"
  static let pendingActionKey = "timerLiveActivity.pendingAction"
  static let pushTokenKey = "timerLiveActivity.pushToken"
  static let pushToStartTokenKey = "timerLiveActivity.pushToStartToken"

  @available(iOS 16.1, *)
  static func saveAction(
    _ action: String,
    state: TimerActivityAttributes.ContentState
  ) {
    UserDefaults(suiteName: suiteName)?.set(
      [
        "action": action,
        "isRunning": state.isRunning,
        "isResting": state.isResting,
        "remainingSeconds": state.currentRemainingSeconds,
      ],
      forKey: pendingActionKey
    )
  }
}
