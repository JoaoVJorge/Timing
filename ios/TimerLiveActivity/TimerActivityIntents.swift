import ActivityKit
import AppIntents
import Foundation

@available(iOS 17.0, *)
struct ToggleTimerIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Pausar ou continuar timer"
  static var openAppWhenRun = false

  @Parameter(title: "Sessão") var sessionId: String

  init() {}

  init(sessionId: String) {
    self.sessionId = sessionId
  }

  func perform() async throws -> some IntentResult {
    guard let activity = Activity<TimerActivityAttributes>.activities.first(
      where: { $0.attributes.sessionId == sessionId }
    ) else {
      return .result()
    }

    var state = activity.content.state
    if state.isRunning {
      state.elapsedSeconds = state.currentElapsedSeconds
      state.isRunning = false
    } else {
      state.startedAt = Date().addingTimeInterval(
        -TimeInterval(state.elapsedSeconds)
      )
      state.isRunning = true
    }
    await activity.update(
      ActivityContent(
        state: state,
        staleDate: nil
      )
    )
    TimerActivitySharedStore.saveAction(
      state.isRunning ? "resume" : "pause",
      state: state
    )
    return .result()
  }
}

@available(iOS 17.0, *)
struct FinishTimerIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Encerrar timer"
  static var openAppWhenRun = false

  @Parameter(title: "Sessão") var sessionId: String

  init() {}

  init(sessionId: String) {
    self.sessionId = sessionId
  }

  func perform() async throws -> some IntentResult {
    guard let activity = Activity<TimerActivityAttributes>.activities.first(
      where: { $0.attributes.sessionId == sessionId }
    ) else {
      return .result()
    }
    var state = activity.content.state
    state.elapsedSeconds = state.currentElapsedSeconds
    state.isRunning = false
    TimerActivitySharedStore.saveAction("finish", state: state)
    await activity.end(
      ActivityContent(state: state, staleDate: nil),
      dismissalPolicy: .immediate
    )
    return .result()
  }
}
