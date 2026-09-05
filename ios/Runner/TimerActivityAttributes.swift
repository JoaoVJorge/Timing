import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct TimerActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var elapsedSeconds: Int
    var startedAt: Date
    var isRunning: Bool
    var isResting: Bool
    var isReading: Bool

    private enum CodingKeys: String, CodingKey {
      case elapsedSeconds
      case startedAt
      case isRunning
      case isResting
      case isReading
      // Compatibility with a Live Activity created by an older build.
      case remainingSeconds
      case endDate
    }

    init(
      elapsedSeconds: Int,
      startedAt: Date,
      isRunning: Bool,
      isResting: Bool,
      isReading: Bool
    ) {
      self.elapsedSeconds = elapsedSeconds
      self.startedAt = startedAt
      self.isRunning = isRunning
      self.isResting = isResting
      self.isReading = isReading
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      elapsedSeconds = try values.decodeIfPresent(
        Int.self,
        forKey: .elapsedSeconds
      ) ?? values.decode(Int.self, forKey: .remainingSeconds)
      startedAt = try values.decodeIfPresent(Date.self, forKey: .startedAt)
        ?? values.decode(Date.self, forKey: .endDate)
      isRunning = try values.decode(Bool.self, forKey: .isRunning)
      isResting = try values.decode(Bool.self, forKey: .isResting)
      isReading = try values.decodeIfPresent(Bool.self, forKey: .isReading)
        ?? false
    }

    func encode(to encoder: Encoder) throws {
      var values = encoder.container(keyedBy: CodingKeys.self)
      try values.encode(elapsedSeconds, forKey: .elapsedSeconds)
      try values.encode(startedAt, forKey: .startedAt)
      try values.encode(isRunning, forKey: .isRunning)
      try values.encode(isResting, forKey: .isResting)
      try values.encode(isReading, forKey: .isReading)
    }

    var currentElapsedSeconds: Int {
      guard isRunning else { return max(0, elapsedSeconds) }
      return max(0, Int(Date().timeIntervalSince(startedAt).rounded(.down)))
    }
  }

  let sessionId: String
  let subjectName: String
  let colorHex: String
}

enum TimerActivitySharedStore {
  static let suiteName = "group.com.moonstone.timing"
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
        "elapsedSeconds": state.currentElapsedSeconds,
      ],
      forKey: pendingActionKey
    )
  }
}
