import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel: TasksViewModel

    init(taskUseCases: TaskUseCases) {
        _viewModel = StateObject(wrappedValue: TasksViewModel(taskUseCases: taskUseCases))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 14) {
                addTaskBar

                List {
                    ForEach(viewModel.tasks) { task in
                        taskRow(task)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
            .padding(.top, 4)
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("New task", text: $viewModel.newTaskTitle)
                .textFieldStyle(.plain)
                .font(AppTypography.body())
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.white.opacity(0.9))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
                }
                .cornerRadius(14)

            Button("Add") {
                viewModel.addTask()
            }
            .buttonStyle(.plain)
            .font(AppTypography.section(15))
            .foregroundColor(.white)
            .frame(height: 46)
            .padding(.horizontal, 16)
            .background(
                LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .shadow(color: AppTheme.primaryDeep.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)
    }

    private func taskRow(_ task: TaskItem) -> some View {
        HStack(spacing: 10) {
            Button {
                viewModel.toggleTask(task)
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(task.isDone ? AppTheme.accent : AppTheme.textSecondary)
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(AppTypography.section())
                .foregroundColor(AppTheme.textPrimary)
                .strikethrough(task.isDone)
                .lineLimit(2)

            Spacer()

            if task.isDone {
                Text("Done")
                    .font(AppTypography.caption(12))
                    .foregroundColor(AppTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.accent.opacity(0.12))
                    .cornerRadius(8)
            }
        }
        .padding(14)
        .background(AppTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
        }
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
    }
}
