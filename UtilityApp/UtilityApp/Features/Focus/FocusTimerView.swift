import SwiftUI

struct FocusTimerView: View {
    @StateObject private var viewModel: FocusTimerViewModel

    init(focusUseCases: FocusUseCases) {
        _viewModel = StateObject(wrappedValue: FocusTimerViewModel(focusUseCases: focusUseCases))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: stackSpacing) {
                Text(timeText)
                    .font(.system(size: timerFontSize, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(AppTheme.primary)

                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .tint(AppTheme.accent)
                    .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)

                Picker("Minutes", selection: $viewModel.selectedMinutes) {
                    Text("15").tag(15)
                    Text("25").tag(25)
                    Text("40").tag(40)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)

                HStack(spacing: 12) {
                    Button(startPauseTitle) {
                        viewModel.startPause()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)

                    Button("Reset") {
                        viewModel.reset()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding(.top, topPadding)
            .background(AppTheme.background)
            .navigationTitle("Focus")
        }
    }

    private var timeText: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var startPauseTitle: String {
        if viewModel.isRunning {
            return "Pause"
        }
        return "Start"
    }

    private var stackSpacing: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 16
        }
        return 24
    }

    private var topPadding: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 20
        }
        return 40
    }

    private var timerFontSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 46
        }
        return 56
    }
}
