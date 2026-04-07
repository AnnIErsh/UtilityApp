import Foundation

protocol DataService {
    func fetchTasks() async -> [TaskItem]
    func addTask(title: String, dueDate: Date?) async
    func toggleTask(id: UUID) async
    func deleteTask(id: UUID) async

    func fetchHabits() async -> [HabitItem]
    func addHabit(name: String, targetPerWeek: Int) async
    func incrementHabit(id: UUID) async

    func fetchFocusSessions() async -> [FocusSessionItem]
    func saveFocusSession(durationMinutes: Int) async
}
