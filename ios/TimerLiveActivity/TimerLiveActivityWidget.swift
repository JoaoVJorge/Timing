import ActivityKit
import SwiftUI
import WidgetKit

struct TimerLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TimerActivityAttributes.self) { context in
      LockScreenTimerView(context: context)
        .activityBackgroundTint(Color.black.opacity(0.9))
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          TimerText(state: context.state, fontSize: 28)
            .frame(minWidth: 102, alignment: .leading)
        }
        DynamicIslandExpandedRegion(.trailing) {
          TimerActions(context: context, compact: true)
        }
        DynamicIslandExpandedRegion(.bottom) {
          HStack(spacing: 7) {
            Circle()
              .fill(Color(hex: context.attributes.colorHex))
              .frame(width: 7, height: 7)
            Text(context.attributes.subjectName)
              .font(.caption.weight(.semibold))
              .lineLimit(1)
            Spacer()
            Text(context.state.isResting ? "Pausa" : "Foco")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
      } compactLeading: {
        Image(systemName: context.state.isResting ? "cup.and.saucer.fill" : "timer")
          .foregroundStyle(Color(hex: context.attributes.colorHex))
      } compactTrailing: {
        TimerText(state: context.state, fontSize: 13)
          .foregroundStyle(Color(hex: context.attributes.colorHex))
          .frame(maxWidth: 56)
      } minimal: {
        Image(systemName: context.state.isRunning ? "timer" : "pause.fill")
          .foregroundStyle(Color(hex: context.attributes.colorHex))
      }
      .keylineTint(Color(hex: context.attributes.colorHex))
    }
  }
}

private struct LockScreenTimerView: View {
  let context: ActivityViewContext<TimerActivityAttributes>

  var body: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .stroke(Color.white.opacity(0.14), lineWidth: 8)
        Circle()
          .trim(from: 0.08, to: 0.72)
          .stroke(
            Color(hex: context.attributes.colorHex),
            style: StrokeStyle(lineWidth: 8, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
      }
      .frame(width: 66, height: 66)

      VStack(alignment: .leading, spacing: 5) {
        TimerText(state: context.state, fontSize: 38)
        HStack(spacing: 7) {
          Circle()
            .fill(Color(hex: context.attributes.colorHex))
            .frame(width: 7, height: 7)
          Text(context.attributes.subjectName)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
        }
        Text(context.state.isResting ? "Pausa da sessão" : "Foco · Sessão de estudo")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 4)
      TimerActions(context: context, compact: false)
    }
    .padding(16)
  }
}

private struct TimerActions: View {
  let context: ActivityViewContext<TimerActivityAttributes>
  let compact: Bool

  var body: some View {
    if #available(iOS 17.0, *) {
      VStack(spacing: compact ? 6 : 9) {
        Button(intent: ToggleTimerIntent(sessionId: context.attributes.sessionId)) {
          Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
            .font(.system(size: compact ? 13 : 18, weight: .bold))
            .frame(width: compact ? 32 : 48, height: compact ? 28 : 43)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(Color(hex: context.attributes.colorHex), in: RoundedRectangle(cornerRadius: compact ? 10 : 14))

        Button(intent: FinishTimerIntent(sessionId: context.attributes.sessionId)) {
          Image(systemName: "xmark")
            .font(.system(size: compact ? 13 : 18, weight: .bold))
            .frame(width: compact ? 32 : 48, height: compact ? 28 : 43)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.black)
        .background(.white, in: RoundedRectangle(cornerRadius: compact ? 10 : 14))
      }
    } else {
      Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
        .foregroundStyle(Color(hex: context.attributes.colorHex))
    }
  }
}

private struct TimerText: View {
  let state: TimerActivityAttributes.ContentState
  let fontSize: CGFloat

  var body: some View {
    Group {
      if state.isRunning {
        Text(
          timerInterval: Date()...max(Date().addingTimeInterval(1), state.endDate),
          countsDown: true,
          showsHours: true
        )
      } else {
        Text(formatDuration(state.remainingSeconds))
      }
    }
    .font(.system(size: fontSize, weight: .bold, design: .rounded))
    .monospacedDigit()
    .lineLimit(1)
  }

  private func formatDuration(_ seconds: Int) -> String {
    let safe = max(0, seconds)
    let hours = safe / 3600
    let minutes = (safe % 3600) / 60
    let remainder = safe % 60
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, remainder)
    }
    return String(format: "%02d:%02d", minutes, remainder)
  }
}

private extension Color {
  init(hex: String) {
    let value = UInt64(hex, radix: 16) ?? 0x8B5CF6
    self.init(
      .sRGB,
      red: Double((value >> 16) & 0xFF) / 255,
      green: Double((value >> 8) & 0xFF) / 255,
      blue: Double(value & 0xFF) / 255,
      opacity: 1
    )
  }
}
