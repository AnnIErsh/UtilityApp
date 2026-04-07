import Foundation

struct TaskUseCases {
    let fetchTasks: () async -> [TaskItem]
    let addTask: (_ title: String, _ dueDate: Date?) async -> Void
    let toggleTask: (_ id: UUID) async -> Void
    let deleteTask: (_ id: UUID) async -> Void
}
