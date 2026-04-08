import Foundation

struct FocusUseCases {
    let fetchFocusSessions: () async -> [FocusSessionItem]
    let saveFocusSession: (_ durationMinutes: Int) async -> Void
    let requestNotificationAccess: () async -> Void
    let scheduleRunningNotification: (_ secondsLeft: Int) async -> Void
    let scheduleCompletionNotification: (_ seconds: Int) async -> Void
    let cancelFocusNotifications: () async -> Void
}
