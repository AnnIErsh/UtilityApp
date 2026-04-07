import SwiftUI

struct MainTabView: View {
    private let useCases: AppUseCaseFactory
    @StateObject private var viewModel = MainTabViewModel()

    init(locator: ServiceLocator) {
        self.useCases = locator.resolve(AppUseCaseFactory.self)
    }

    var body: some View {
        ZStack {
            ForEach(viewModel.tabs) { tab in
                tabContent(tab)
                    .opacity(viewModel.layerOpacity(for: tab))
                    .allowsHitTesting(viewModel.isSelected(tab))
                    .accessibilityHidden(!viewModel.isSelected(tab))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: viewModel.selectedTab)
        .safeAreaInset(edge: .bottom) {
            customTabBar
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
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                }
                .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 6)
                .frame(height: 68)

            GeometryReader { proxy in
                let metrics = viewModel.indicatorMetrics(totalWidth: proxy.size.width)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primary.opacity(0.20), AppTheme.accent.opacity(0.16), Color.white.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.78), lineWidth: 0.8)
                    }
                    .frame(width: metrics.width, height: 52)
                    .offset(x: metrics.x, y: 8)
                    .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                viewModel.updateDrag(translation: value.translation.width)
                            }
                            .onEnded { value in
                                withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.86, blendDuration: 0.2)) {
                                    viewModel.endDrag(
                                        totalWidth: proxy.size.width,
                                        predictedTranslation: value.predictedEndTranslation.width
                                    )
                                }
                            }
                    )
            }
            .frame(height: 68)

            HStack(spacing: 0) {
                ForEach(viewModel.tabs) { tab in
                    Button {
                        withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.88, blendDuration: 0.2)) {
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
                        .foregroundColor(viewModel.isSelected(tab) ? AppTheme.primaryDeep : AppTheme.textPrimary.opacity(0.78))
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .allowsHitTesting(!viewModel.isDraggingIndicator)
            .frame(height: 68)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
}
