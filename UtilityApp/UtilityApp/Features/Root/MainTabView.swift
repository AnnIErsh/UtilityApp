import SwiftUI

private enum AppTab: Int, CaseIterable {
    case home
    case tasks
    case focus
    case habits
    case stats

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .focus: return "Focus"
        case .habits: return "Habits"
        case .stats: return "Stats"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .focus: return "timer"
        case .habits: return "leaf.fill"
        case .stats: return "chart.bar.fill"
        }
    }
}

struct MainTabView: View {
    private let useCases: AppUseCaseFactory
    @State private var selectedTab: AppTab = .home

    init(locator: ServiceLocator) {
        self.useCases = locator.resolve(AppUseCaseFactory.self)
    }

    var body: some View {
        selectedContent
            .safeAreaInset(edge: .bottom) {
                customTabBar
            }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .home:
            DashboardView(
                taskUseCases: useCases.taskUseCases,
                habitUseCases: useCases.habitUseCases,
                focusUseCases: useCases.focusUseCases
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
                focusUseCases: useCases.focusUseCases
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
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                .frame(height: 68)

            GeometryReader { proxy in
                let tabWidth = proxy.size.width / CGFloat(AppTab.allCases.count)
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.65))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.7), lineWidth: 0.8)
                    }
                    .frame(width: tabWidth - 8, height: 52)
                    .offset(x: CGFloat(selectedTab.rawValue) * tabWidth + 4, y: 8)
                    .animation(.interactiveSpring(response: 0.30, dampingFraction: 0.92), value: selectedTab)
            }
            .frame(height: 68)

            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                            Text(tab.title)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(tab == selectedTab ? AppTheme.primary : .primary.opacity(0.85))
                        .padding(.vertical, 10)
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
