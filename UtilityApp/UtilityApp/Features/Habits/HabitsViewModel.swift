import Combine
import Foundation

@MainActor
final class HabitsViewModel: ObservableObject {
    @Published private(set) var habits: [HabitItem] = []
    @Published var newHabitName: String = ""

    private let habitUseCases: HabitUseCases
    private let habitOrderKey = "habits.order.ids"

    init(habitUseCases: HabitUseCases) {
        self.habitUseCases = habitUseCases
    }

    func reload() {
        Task {
            let fetched = await habitUseCases.fetchHabits()
            let ordered = applyOrder(to: fetched)
            habits = ordered
            persistOrder(from: ordered)
        }
    }

    func addHabit() {
        let name = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        Task {
            let existingIDs = Set(habits.map(\.id))
            await habitUseCases.addHabit(name, 5)
            newHabitName = ""

            let fetched = await habitUseCases.fetchHabits()
            let fetchedIDs = Set(fetched.map(\.id))
            let newlyInsertedIDs = fetchedIDs.subtracting(existingIDs)
            let ordered = applyOrder(to: fetched, prioritize: newlyInsertedIDs)
            habits = ordered
            persistOrder(from: ordered)
        }
    }

    func incrementHabit(_ habit: HabitItem) {
        Task {
            await habitUseCases.incrementHabit(habit.id)
            let fetched = await habitUseCases.fetchHabits()
            let ordered = applyOrder(to: fetched)
            habits = ordered
            persistOrder(from: ordered)
        }
    }

    func deleteHabit(_ habit: HabitItem) {
        Task {
            await habitUseCases.deleteHabit(habit.id)
            let fetched = await habitUseCases.fetchHabits()
            let ordered = applyOrder(to: fetched)
            habits = ordered
            persistOrder(from: ordered)
        }
    }

    func deleteHabits(at offsets: IndexSet) {
        let items = offsets.compactMap { habits[safe: $0] }

        Task {
            for habit in items {
                await habitUseCases.deleteHabit(habit.id)
            }
            let fetched = await habitUseCases.fetchHabits()
            let ordered = applyOrder(to: fetched)
            habits = ordered
            persistOrder(from: ordered)
        }
    }

    private func applyOrder(to items: [HabitItem], prioritize prioritizedIDs: Set<UUID> = []) -> [HabitItem] {
        let storedOrder = loadStoredOrder()
        let indexByID = Dictionary(uniqueKeysWithValues: storedOrder.enumerated().map { ($1, $0) })

        return items.sorted { lhs, rhs in
            let lhsIsNew = prioritizedIDs.contains(lhs.id)
            let rhsIsNew = prioritizedIDs.contains(rhs.id)
            if lhsIsNew != rhsIsNew {
                return lhsIsNew
            }

            let lhsIndex = indexByID[lhs.id]
            let rhsIndex = indexByID[rhs.id]
            switch (lhsIndex, rhsIndex) {
            case let (l?, r?):
                return l < r
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }

    private func persistOrder(from items: [HabitItem]) {
        let ids = items.map { $0.id.uuidString }
        UserDefaults.standard.set(ids, forKey: habitOrderKey)
    }

    private func loadStoredOrder() -> [UUID] {
        let raw = UserDefaults.standard.array(forKey: habitOrderKey) as? [String] ?? []
        return raw.compactMap(UUID.init(uuidString:))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
