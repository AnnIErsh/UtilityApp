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
                    .font(AppTypography.hero(timerFontSize))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(AppTheme.primaryDeep)

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
                .disabled(viewModel.isRunning)
                .opacity(viewModel.isRunning ? 0.6 : 1)

                VStack(spacing: 10) {
                    Button(startPauseTitle) {
                        viewModel.startPause()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(FocusActionButtonStyle(isPrimary: true))

                    Button("Reset") {
                        viewModel.reset()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(FocusActionButtonStyle(isPrimary: false))
                }
                .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)

                Spacer()
            }
            .padding(.top, topPadding)
            .background(AppTheme.screenBackground.ignoresSafeArea())
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

private struct FocusActionButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.section())
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            }
            .cornerRadius(14)
            .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        if isPrimary {
            return .white
        }
        return AppTheme.primaryDeep
    }

    private var background: some ShapeStyle {
        if isPrimary {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(Color.white.opacity(0.86))
    }

    private var borderColor: Color {
        if isPrimary {
            return Color.white.opacity(0.22)
        }
        return Color.white.opacity(0.7)
    }

    private var shadowColor: Color {
        if isPrimary {
            return AppTheme.primaryDeep.opacity(0.22)
        }
        return AppTheme.cardShadow
    }
}
