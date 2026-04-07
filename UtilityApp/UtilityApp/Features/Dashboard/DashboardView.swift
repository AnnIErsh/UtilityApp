import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(taskUseCases: TaskUseCases, habitUseCases: HabitUseCases, focusUseCases: FocusUseCases) {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                taskUseCases: taskUseCases,
                habitUseCases: habitUseCases,
                focusUseCases: focusUseCases
            )
        )
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    metricCard(title: "Tasks done", value: "\(viewModel.tasksDoneToday)/\(viewModel.totalTasks)", color: AppTheme.primary)
                    metricCard(title: "Focus this week", value: "\(viewModel.focusMinutesWeek) min", color: AppTheme.accent)
                    metricCard(title: "Active habits", value: "\(viewModel.activeHabits)", color: AppTheme.warning)
                }
                .padding(LayoutMetrics.contentHorizontalPadding)
            }
            .background(AppTheme.background)
            .navigationTitle("Today")
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private func metricCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: metricValueFontSize, weight: .bold))
                .minimumScaleFactor(0.8)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.card)
        .cornerRadius(LayoutMetrics.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var metricValueFontSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 24
        }
        return 28
    }
}
