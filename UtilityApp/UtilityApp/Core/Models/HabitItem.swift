import Foundation

struct HabitItem: Identifiable {
    let id: UUID
    let name: String
    let targetPerWeek: Int
    let completedCount: Int
}
