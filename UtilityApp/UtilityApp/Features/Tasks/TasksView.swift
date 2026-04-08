import SwiftUI
import UIKit

struct TasksView: View {
    @StateObject private var viewModel: TasksViewModel
    @FocusState private var isTaskInputFocused: Bool

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
        .sheet(item: $viewModel.selectedTask) { task in
            TaskDetailsSheet(task: task)
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("New task", text: $viewModel.newTaskTitle)
                .textFieldStyle(.plain)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .focused($isTaskInputFocused)
                .font(AppTypography.body())
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(AppTheme.card)
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
        .contentShape(Rectangle())
        .onTapGesture {
            openTaskDetails(task)
        }
    }

    private func openTaskDetails(_ task: TaskItem) {
        isTaskInputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        DispatchQueue.main.async {
            viewModel.showTaskDetails(task)
        }
    }
}

private struct TaskDetailsSheet: View {
    let task: TaskItem
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                statusBadge

                titleCard

                detailCard
            }
            .padding(LayoutMetrics.contentHorizontalPadding)
            .padding(.top, 10)
        }
        .background(sheetBackground.ignoresSafeArea())
    }

    private var statusBadge: some View {
        Text(task.isDone ? "Done" : "In progress")
            .font(AppTypography.caption(13))
            .foregroundColor(task.isDone ? AppTheme.accent : AppTheme.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background((task.isDone ? AppTheme.accent : AppTheme.primary).opacity(0.14))
            .clipShape(Capsule())
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            detailRow(title: "Created", value: Self.formatter.string(from: task.createdAt))
            if let dueDate = task.dueDate {
                detailRow(title: "Due", value: Self.formatter.string(from: dueDate))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: LayoutMetrics.cardCornerRadius)
                .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
        }
        .cornerRadius(LayoutMetrics.cardCornerRadius)
    }

    private var titleCard: some View {
        Text(task.title)
            .font(AppTypography.title(28))
            .foregroundColor(AppTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(AppTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: LayoutMetrics.cardCornerRadius)
                    .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
            }
            .cornerRadius(LayoutMetrics.cardCornerRadius)
            .shadow(color: AppTheme.cardShadow, radius: colorScheme == .dark ? 14 : 8, x: 0, y: 4)
    }

    private var sheetBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color.black.opacity(0.30),
                    AppTheme.background,
                    AppTheme.primary.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return AppTheme.screenBackground
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.caption(13))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(AppTypography.body(14))
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
