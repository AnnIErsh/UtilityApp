import CoreData
import Foundation

final class CoreDataDataService: DataService {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func fetchTasks() async -> [TaskItem] {
        await performContextWork { context in
            let request = TaskEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let entities = (try? context.fetch(request)) ?? []
            return entities.map {
                TaskItem(
                    id: $0.id,
                    title: $0.title,
                    isDone: $0.isDone,
                    createdAt: $0.createdAt,
                    dueDate: $0.dueDate
                )
            }
        }
    }

    func addTask(title: String, dueDate: Date?) async {
        await performContextWork { context in
            let entity = TaskEntity(context: context)
            entity.id = UUID()
            entity.title = title
            entity.isDone = false
            entity.createdAt = Date()
            entity.dueDate = dueDate
            self.stack.saveContext()
        }
    }

    func toggleTask(id: UUID) async {
        await performContextWork { context in
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try? context.fetch(request).first else { return }
            entity.isDone.toggle()
            self.stack.saveContext()
        }
    }

    func deleteTask(id: UUID) async {
        await performContextWork { context in
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try? context.fetch(request).first else { return }
            context.delete(entity)
            self.stack.saveContext()
        }
    }

    func fetchHabits() async -> [HabitItem] {
        await performContextWork { context in
            let request = HabitEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = (try? context.fetch(request)) ?? []
            return entities.map {
                HabitItem(
                    id: $0.id,
                    name: $0.name,
                    targetPerWeek: Int($0.targetPerWeek),
                    completedCount: Int($0.completedCount)
                )
            }
        }
    }

    func addHabit(name: String, targetPerWeek: Int) async {
        await performContextWork { context in
            let entity = HabitEntity(context: context)
            entity.id = UUID()
            entity.name = name
            entity.targetPerWeek = Int16(max(1, targetPerWeek))
            entity.completedCount = 0
            self.stack.saveContext()
        }
    }

    func incrementHabit(id: UUID) async {
        await performContextWork { context in
            let request = HabitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try? context.fetch(request).first else { return }
            entity.completedCount += 1
            self.stack.saveContext()
        }
    }

    func deleteHabit(id: UUID) async {
        await performContextWork { context in
            let request = HabitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try? context.fetch(request).first else { return }
            context.delete(entity)
            self.stack.saveContext()
        }
    }

    func fetchFocusSessions() async -> [FocusSessionItem] {
        await performContextWork { context in
            let request = FocusSessionEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]

            let entities = (try? context.fetch(request)) ?? []
            return entities.map {
                FocusSessionItem(
                    id: $0.id,
                    durationMinutes: Int($0.durationMinutes),
                    completedAt: $0.completedAt
                )
            }
        }
    }

    func saveFocusSession(durationMinutes: Int) async {
        await performContextWork { context in
            let entity = FocusSessionEntity(context: context)
            entity.id = UUID()
            entity.durationMinutes = Int32(max(durationMinutes, 1))
            entity.completedAt = Date()
            self.stack.saveContext()
        }
    }

    private func performContextWork<T>(_ work: @escaping (NSManagedObjectContext) -> T) async -> T {
        await withCheckedContinuation { continuation in
            stack.context.perform {
                let value = work(self.stack.context)
                continuation.resume(returning: value)
            }
        }
    }
}
