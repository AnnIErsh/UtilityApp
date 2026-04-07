import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var showCards = true
    let isActive: Bool

    init(taskUseCases: TaskUseCases, habitUseCases: HabitUseCases, focusUseCases: FocusUseCases, isActive: Bool = true) {
        _viewModel = StateObject(
            wrappedValue: StatsViewModel(
                taskUseCases: taskUseCases,
                habitUseCases: habitUseCases,
                focusUseCases: focusUseCases
            )
        )
        self.isActive = isActive
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                statCard(index: 0, title: "Completed tasks", value: "\(viewModel.completedTasks)")
                statCard(index: 1, title: "Total focus", value: "\(viewModel.totalFocusMinutes) min")
                statCard(index: 2, title: "Best habit progress", value: "\(Int(viewModel.bestHabitRate * 100))%")
                Spacer()
            }
            .padding(LayoutMetrics.contentHorizontalPadding)
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("Stats")
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

    private func statCard(index: Int, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.body(14))
                .foregroundColor(AppTheme.textSecondary)
            Text(value)
                .font(AppTypography.hero(statValueFontSize))
                .minimumScaleFactor(0.8)
                .foregroundColor(AppTheme.primary)
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

    private var statValueFontSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 26
        }
        return 30
    }
}
