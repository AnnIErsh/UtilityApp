import Foundation

struct AppUseCaseFactory {
    let taskUseCases: TaskUseCases
    let habitUseCases: HabitUseCases
    let focusUseCases: FocusUseCases

    init(repository: AppRepository, focusNotificationService: FocusNotificationService) {
        taskUseCases = TaskUseCases(
            fetchTasks: { await repository.fetchTasks() },
            addTask: { title, dueDate in await repository.addTask(title: title, dueDate: dueDate) },
            toggleTask: { id in await repository.toggleTask(id: id) },
            deleteTask: { id in await repository.deleteTask(id: id) }
        )

        habitUseCases = HabitUseCases(
            fetchHabits: { await repository.fetchHabits() },
            addHabit: { name, target in await repository.addHabit(name: name, targetPerWeek: target) },
            incrementHabit: { id in await repository.incrementHabit(id: id) },
            deleteHabit: { id in await repository.deleteHabit(id: id) }
        )

        focusUseCases = FocusUseCases(
            fetchFocusSessions: { await repository.fetchFocusSessions() },
            saveFocusSession: { duration in await repository.saveFocusSession(durationMinutes: duration) },
            requestNotificationAccess: { await focusNotificationService.requestAuthorizationIfNeeded() },
            scheduleRunningNotification: { secondsLeft in
                await focusNotificationService.scheduleRunningNotification(secondsLeft: secondsLeft)
            },
            scheduleCompletionNotification: { seconds in
                await focusNotificationService.scheduleCompletionNotification(in: seconds)
            },
            cancelFocusNotifications: { await focusNotificationService.cancelAllFocusNotifications() }
        )
    }
}
