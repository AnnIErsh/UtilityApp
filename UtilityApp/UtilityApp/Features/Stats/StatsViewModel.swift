import Combine
import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var completedTasks: Int = 0
    @Published private(set) var totalFocusMinutes: Int = 0
    @Published private(set) var bestHabitRate: Double = 0

    private let taskUseCases: TaskUseCases
    private let habitUseCases: HabitUseCases
    private let focusUseCases: FocusUseCases

    init(taskUseCases: TaskUseCases, habitUseCases: HabitUseCases, focusUseCases: FocusUseCases) {
        self.taskUseCases = taskUseCases
        self.habitUseCases = habitUseCases
        self.focusUseCases = focusUseCases
    }

    func reload() {
        Task {
            let tasks = await taskUseCases.fetchTasks()
            completedTasks = tasks.filter { $0.isDone }.count

            let sessions = await focusUseCases.fetchFocusSessions()
            totalFocusMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }

            let habits = await habitUseCases.fetchHabits()
            bestHabitRate = habits
                .map { Double($0.completedCount) / Double(max($0.targetPerWeek, 1)) }
                .max() ?? 0
        }
    }
}
