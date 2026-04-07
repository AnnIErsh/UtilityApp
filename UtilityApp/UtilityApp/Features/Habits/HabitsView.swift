import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel: HabitsViewModel

    init(habitUseCases: HabitUseCases) {
        _viewModel = StateObject(wrappedValue: HabitsViewModel(habitUseCases: habitUseCases))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    TextField("New habit", text: $viewModel.newHabitName)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        viewModel.addHabit()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)
                }
                .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)

                List(viewModel.habits) { habit in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(habit.name)
                                .font(.headline)
                            Text("\(habit.completedCount)/\(habit.targetPerWeek) this week")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button {
                            viewModel.incrementHabit(habit)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.accent)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            .background(AppTheme.background)
            .navigationTitle("Habits")
        }
        .onAppear {
            viewModel.reload()
        }
    }
}
