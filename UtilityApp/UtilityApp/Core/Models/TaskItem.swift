import Foundation

struct TaskItem: Identifiable {
    let id: UUID
    let title: String
    let isDone: Bool
    let createdAt: Date
    let dueDate: Date?
}
