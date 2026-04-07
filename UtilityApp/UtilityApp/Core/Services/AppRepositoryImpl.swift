import Foundation

final class AppRepositoryImpl: AppRepository {
    private let dataService: DataService

    init(dataService: DataService) {
        self.dataService = dataService
    }

    func fetchTasks() async -> [TaskItem] {
        await dataService.fetchTasks()
    }

    func addTask(title: String, dueDate: Date?) async {
        await dataService.addTask(title: title, dueDate: dueDate)
    }

    func toggleTask(id: UUID) async {
        await dataService.toggleTask(id: id)
    }

    func deleteTask(id: UUID) async {
        await dataService.deleteTask(id: id)
    }

    func fetchHabits() async -> [HabitItem] {
        await dataService.fetchHabits()
    }

    func addHabit(name: String, targetPerWeek: Int) async {
        await dataService.addHabit(name: name, targetPerWeek: targetPerWeek)
    }

    func incrementHabit(id: UUID) async {
        await dataService.incrementHabit(id: id)
    }

    func deleteHabit(id: UUID) async {
        await dataService.deleteHabit(id: id)
    }

    func fetchFocusSessions() async -> [FocusSessionItem] {
        await dataService.fetchFocusSessions()
    }

    func saveFocusSession(durationMinutes: Int) async {
        await dataService.saveFocusSession(durationMinutes: durationMinutes)
    }
}
