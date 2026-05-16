import ActivityKit
import WidgetKit
import SwiftUI

struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // MARK: LOCK SCREEN
            VStack {
                Text(context.state.phaseName)
                    .font(.headline)
                    .foregroundColor(.purple)
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
            }
            .padding()
        } dynamicIsland: { context in
            // MARK: DYNAMIC ISLAND
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            } compactLeading: {
                Image(systemName: "brain")
                    .foregroundColor(.purple)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .foregroundColor(.purple)
                    .frame(maxWidth: 40)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "brain")
                    .foregroundColor(.purple)
            }
            .keylineTint(Color.purple)
        }
    }
}
