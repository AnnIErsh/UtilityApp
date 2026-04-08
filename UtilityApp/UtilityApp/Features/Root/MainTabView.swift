import SwiftUI

private struct TabBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct MainTabView: View {
    private let useCases: AppUseCaseFactory
    @StateObject private var viewModel = MainTabViewModel()
    @State private var isKeyboardVisible = false
    @State private var tabBarHeight: CGFloat = 0

    init(locator: ServiceLocator) {
        self.useCases = locator.resolve(AppUseCaseFactory.self)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent(viewModel.selectedTab)
                .padding(.bottom, isKeyboardVisible ? 0 : tabBarHeight)
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTab)

            if !isKeyboardVisible {
                customTabBar
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: TabBarHeightKey.self, value: geo.size.height)
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .onPreferenceChange(TabBarHeightKey.self) { value in
            tabBarHeight = value
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeOut(duration: 0.18)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.18)) {
                isKeyboardVisible = false
            }
        }
    }

    @ViewBuilder
    private func tabContent(_ tab: AppTab) -> some View {
        switch tab {
        case .home:
            DashboardView(
                taskUseCases: useCases.taskUseCases,
                habitUseCases: useCases.habitUseCases,
                focusUseCases: useCases.focusUseCases,
                isActive: viewModel.isSelected(.home)
            )
        case .tasks:
            TasksView(taskUseCases: useCases.taskUseCases)
        case .focus:
            FocusTimerView(focusUseCases: useCases.focusUseCases)
        case .habits:
            HabitsView(habitUseCases: useCases.habitUseCases)
        case .stats:
            StatsView(
                taskUseCases: useCases.taskUseCases,
                habitUseCases: useCases.habitUseCases,
                focusUseCases: useCases.focusUseCases,
                isActive: viewModel.isSelected(.stats)
            )
        }
    }

    private var customTabBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                }
                .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 6)
                .frame(height: 68)

            HStack(spacing: 0) {
                ForEach(viewModel.tabs) { tab in
                    Button {
                        withAnimation(.interactiveSpring(response: 0.30, dampingFraction: 0.90)) {
                            viewModel.selectTab(tab)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                            Text(tab.title)
                                .font(AppTypography.caption())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if viewModel.isSelected(tab) {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.primary.opacity(0.20), AppTheme.accent.opacity(0.14), Color.white.opacity(0.75)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.78), lineWidth: 0.8)
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 4)
                            }
                        }
                        .foregroundColor(viewModel.isSelected(tab) ? AppTheme.primaryDeep : AppTheme.textPrimary.opacity(0.78))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 68)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
}
