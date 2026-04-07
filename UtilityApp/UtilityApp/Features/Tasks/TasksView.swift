import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel: TasksViewModel

    init(taskUseCases: TaskUseCases) {
        _viewModel = StateObject(wrappedValue: TasksViewModel(taskUseCases: taskUseCases))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    TextField("New task", text: $viewModel.newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        viewModel.addTask()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)
                }
                .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)

                List {
                    ForEach(viewModel.tasks) { task in
                        HStack {
                            Image(systemName: iconName(for: task))
                                .foregroundColor(iconColor(for: task))
                            Text(task.title)
                                .strikethrough(task.isDone)
                                .lineLimit(2)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleTask(task)
                        }
                    }
                    .onDelete(perform: viewModel.deleteTask)
                }
                .listStyle(.plain)
            }
            .background(AppTheme.background)
            .navigationTitle("Tasks")
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private func iconName(for task: TaskItem) -> String {
        if task.isDone {
            return "checkmark.circle.fill"
        }
        return "circle"
    }

    private func iconColor(for task: TaskItem) -> Color {
        if task.isDone {
            return AppTheme.accent
        }
        return .gray
    }
}
