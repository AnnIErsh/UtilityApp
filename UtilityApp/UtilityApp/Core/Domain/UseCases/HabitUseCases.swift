import Foundation

struct HabitUseCases {
    let fetchHabits: () async -> [HabitItem]
    let addHabit: (_ name: String, _ targetPerWeek: Int) async -> Void
    let incrementHabit: (_ id: UUID) async -> Void
}
