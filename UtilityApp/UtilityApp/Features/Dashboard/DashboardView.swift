import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showCards = true
    let isActive: Bool

    init(taskUseCases: TaskUseCases, habitUseCases: HabitUseCases, focusUseCases: FocusUseCases, isActive: Bool = true) {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                taskUseCases: taskUseCases,
                habitUseCases: habitUseCases,
                focusUseCases: focusUseCases
            )
        )
        self.isActive = isActive
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    metricCard(index: 0, title: "Tasks done", value: "\(viewModel.tasksDoneToday)/\(viewModel.totalTasks)", color: AppTheme.primary)
                    metricCard(index: 1, title: "Focus this week", value: "\(viewModel.focusMinutesWeek) min", color: AppTheme.accent)
                    metricCard(index: 2, title: "Active habits", value: "\(viewModel.activeHabits)", color: AppTheme.warning)
                }
                .padding(LayoutMetrics.contentHorizontalPadding)
            }
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
        .task(id: isActive) {
            refreshIfNeeded()
        }
    }

    private func refreshIfNeeded() {
        guard isActive else { return }
        viewModel.reload()
        showCards = true
    }

    private func metricCard(index: Int, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.body(14))
                .foregroundColor(AppTheme.textSecondary)
            Text(value)
                .font(AppTypography.hero(metricValueFontSize))
                .minimumScaleFactor(0.8)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: LayoutMetrics.cardCornerRadius)
                .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
        }
        .cornerRadius(LayoutMetrics.cardCornerRadius)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 6)
        .offset(y: showCards ? 0 : 14)
        .opacity(showCards ? 1 : 0.001)
        .animation(.easeOut(duration: 0.42).delay(Double(index) * 0.06), value: showCards)
    }

    private var metricValueFontSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 24
        }
        return 28
    }
}
