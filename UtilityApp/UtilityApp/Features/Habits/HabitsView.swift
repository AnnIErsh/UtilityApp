import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel: HabitsViewModel

    init(habitUseCases: HabitUseCases) {
        _viewModel = StateObject(wrappedValue: HabitsViewModel(habitUseCases: habitUseCases))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 14) {
                addHabitBar

                List {
                    ForEach(viewModel.habits) { habit in
                        habitRow(habit)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteHabit(habit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
            .padding(.top, 4)
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private var addHabitBar: some View {
        HStack(spacing: 10) {
            TextField("New habit", text: $viewModel.newHabitName)
                .textFieldStyle(.plain)
                .font(AppTypography.body())
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.white.opacity(0.9))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
                }
                .cornerRadius(14)

            Button("Add") {
                viewModel.addHabit()
            }
            .buttonStyle(.plain)
            .font(AppTypography.section(15))
            .foregroundColor(.white)
            .frame(height: 46)
            .padding(.horizontal, 16)
            .background(
                LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .shadow(color: AppTheme.primaryDeep.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)
    }

    private func habitRow(_ habit: HabitItem) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(AppTypography.section())
                        .foregroundColor(AppTheme.textPrimary)
                    Text("\(habit.completedCount)/\(habit.targetPerWeek) this week")
                        .font(AppTypography.caption(13))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Button {
                    viewModel.incrementHabit(habit)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.accent)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            progressBar(for: habit)
        }
        .padding(14)
        .background(AppTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
        }
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
    }

    private func progressBar(for habit: HabitItem) -> some View {
        let ratio = min(Double(habit.completedCount) / Double(max(habit.targetPerWeek, 1)), 1)

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.8))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accent, AppTheme.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * ratio)
            }
        }
        .frame(height: 8)
    }
}
