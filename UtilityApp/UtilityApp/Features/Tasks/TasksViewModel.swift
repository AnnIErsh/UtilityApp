import Combine
import Foundation

@MainActor
final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var newTaskTitle: String = ""

    private let taskUseCases: TaskUseCases

    init(taskUseCases: TaskUseCases) {
        self.taskUseCases = taskUseCases
    }

    func reload() {
        Task {
            tasks = await taskUseCases.fetchTasks()
        }
    }

    func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        Task {
            await taskUseCases.addTask(title, nil)
            newTaskTitle = ""
            tasks = await taskUseCases.fetchTasks()
        }
    }

    func toggleTask(_ task: TaskItem) {
        Task {
            await taskUseCases.toggleTask(task.id)
            tasks = await taskUseCases.fetchTasks()
        }
    }

    func deleteTask(at offsets: IndexSet) {
        let ids = offsets.compactMap { tasks[safe: $0]?.id }

        Task {
            for id in ids {
                await taskUseCases.deleteTask(id)
            }
            tasks = await taskUseCases.fetchTasks()
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
