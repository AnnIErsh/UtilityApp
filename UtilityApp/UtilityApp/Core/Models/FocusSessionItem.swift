import Foundation

struct FocusSessionItem: Identifiable {
    let id: UUID
    let durationMinutes: Int
    let completedAt: Date
}
