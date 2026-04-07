import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var tasksDoneToday: Int = 0
    @Published private(set) var totalTasks: Int = 0
    @Published private(set) var focusMinutesWeek: Int = 0
    @Published private(set) var activeHabits: Int = 0

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
            totalTasks = tasks.count
            tasksDoneToday = tasks.filter { $0.isDone }.count

            let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let sessions = await focusUseCases.fetchFocusSessions()
            focusMinutesWeek = sessions
                .filter { $0.completedAt >= weekStart }
                .reduce(0) { $0 + $1.durationMinutes }

            let habits = await habitUseCases.fetchHabits()
            activeHabits = habits.count
        }
    }
}
