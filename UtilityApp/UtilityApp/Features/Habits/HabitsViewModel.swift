import Combine
import Foundation

@MainActor
final class HabitsViewModel: ObservableObject {
    @Published private(set) var habits: [HabitItem] = []
    @Published var newHabitName: String = ""

    private let habitUseCases: HabitUseCases

    init(habitUseCases: HabitUseCases) {
        self.habitUseCases = habitUseCases
    }

    func reload() {
        Task {
            habits = await habitUseCases.fetchHabits()
        }
    }

    func addHabit() {
        let name = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        Task {
            await habitUseCases.addHabit(name, 5)
            newHabitName = ""
            habits = await habitUseCases.fetchHabits()
        }
    }

    func incrementHabit(_ habit: HabitItem) {
        Task {
            await habitUseCases.incrementHabit(habit.id)
            habits = await habitUseCases.fetchHabits()
        }
    }

    func deleteHabit(_ habit: HabitItem) {
        Task {
            await habitUseCases.deleteHabit(habit.id)
            habits = await habitUseCases.fetchHabits()
        }
    }

    func deleteHabits(at offsets: IndexSet) {
        let items = offsets.compactMap { habits[safe: $0] }

        Task {
            for habit in items {
                await habitUseCases.deleteHabit(habit.id)
            }
            habits = await habitUseCases.fetchHabits()
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
