import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel

    init(taskUseCases: TaskUseCases, habitUseCases: HabitUseCases, focusUseCases: FocusUseCases) {
        _viewModel = StateObject(
            wrappedValue: StatsViewModel(
                taskUseCases: taskUseCases,
                habitUseCases: habitUseCases,
                focusUseCases: focusUseCases
            )
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                statCard(title: "Completed tasks", value: "\(viewModel.completedTasks)")
                statCard(title: "Total focus", value: "\(viewModel.totalFocusMinutes) min")
                statCard(title: "Best habit progress", value: "\(Int(viewModel.bestHabitRate * 100))%")
                Spacer()
            }
            .padding(LayoutMetrics.contentHorizontalPadding)
            .background(AppTheme.background)
            .navigationTitle("Stats")
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: statValueFontSize, weight: .bold))
                .minimumScaleFactor(0.8)
                .foregroundColor(AppTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.card)
        .cornerRadius(LayoutMetrics.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var statValueFontSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 26
        }
        return 30
    }
}
