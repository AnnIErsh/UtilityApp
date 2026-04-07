import CoreData
import Foundation

@objc(TaskEntity)
final class TaskEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var isDone: Bool
    @NSManaged var createdAt: Date
    @NSManaged var dueDate: Date?
}

extension TaskEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
}

@objc(HabitEntity)
final class HabitEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var targetPerWeek: Int16
    @NSManaged var completedCount: Int16
}

extension HabitEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<HabitEntity> {
        NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }
}

@objc(FocusSessionEntity)
final class FocusSessionEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var durationMinutes: Int32
    @NSManaged var completedAt: Date
}

extension FocusSessionEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<FocusSessionEntity> {
        NSFetchRequest<FocusSessionEntity>(entityName: "FocusSessionEntity")
    }
}
