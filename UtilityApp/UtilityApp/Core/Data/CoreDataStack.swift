import CoreData
import Foundation

final class CoreDataStack {
    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        persistentContainer = NSPersistentContainer(name: "UtilityAppModel", managedObjectModel: model)

        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData loading error: \(error.localizedDescription)")
            }
        }

        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("CoreData save error: \(error.localizedDescription)")
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let taskEntity = NSEntityDescription()
        taskEntity.name = "TaskEntity"
        taskEntity.managedObjectClassName = NSStringFromClass(TaskEntity.self)
        taskEntity.properties = [
            makeAttribute(name: "id", type: .UUIDAttributeType, isOptional: false),
            makeAttribute(name: "title", type: .stringAttributeType, isOptional: false),
            makeAttribute(name: "isDone", type: .booleanAttributeType, isOptional: false),
            makeAttribute(name: "createdAt", type: .dateAttributeType, isOptional: false),
            makeAttribute(name: "dueDate", type: .dateAttributeType, isOptional: true)
        ]

        let habitEntity = NSEntityDescription()
        habitEntity.name = "HabitEntity"
        habitEntity.managedObjectClassName = NSStringFromClass(HabitEntity.self)
        habitEntity.properties = [
            makeAttribute(name: "id", type: .UUIDAttributeType, isOptional: false),
            makeAttribute(name: "name", type: .stringAttributeType, isOptional: false),
            makeAttribute(name: "targetPerWeek", type: .integer16AttributeType, isOptional: false),
            makeAttribute(name: "completedCount", type: .integer16AttributeType, isOptional: false)
        ]

        let focusEntity = NSEntityDescription()
        focusEntity.name = "FocusSessionEntity"
        focusEntity.managedObjectClassName = NSStringFromClass(FocusSessionEntity.self)
        focusEntity.properties = [
            makeAttribute(name: "id", type: .UUIDAttributeType, isOptional: false),
            makeAttribute(name: "durationMinutes", type: .integer32AttributeType, isOptional: false),
            makeAttribute(name: "completedAt", type: .dateAttributeType, isOptional: false)
        ]

        model.entities = [taskEntity, habitEntity, focusEntity]
        return model
    }

    private static func makeAttribute(name: String, type: NSAttributeType, isOptional: Bool) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = isOptional
        return attribute
    }
}
