import Foundation
import UserNotifications

protocol FocusNotificationService {
    func requestAuthorizationIfNeeded() async
    func scheduleRunningNotification(secondsLeft: Int) async
    func scheduleCompletionNotification(in seconds: Int) async
    func cancelAllFocusNotifications() async
}

enum FocusNotificationConstants {
    static let categoryID = "FOCUS_TIMER_CATEGORY"
    static let pauseActionID = "FOCUS_PAUSE_ACTION"
    static let runningNotificationID = "FOCUS_RUNNING_NOTIFICATION"
    static let completionNotificationID = "FOCUS_COMPLETION_NOTIFICATION"
    static let pauseRequestedKey = "focus.timer.pauseRequested"
    static let completionTappedKey = "focus.timer.completionTapped"
}

final class LocalFocusNotificationService: FocusNotificationService {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorizationIfNeeded() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleRunningNotification(secondsLeft: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [FocusNotificationConstants.runningNotificationID])

        let minutesLeft = max(Int(ceil(Double(secondsLeft) / 60.0)), 1)
        let content = UNMutableNotificationContent()
        content.title = "Focus in progress"
        content.body = "\(minutesLeft) min left. You can pause from here."
        content.sound = .default
        content.categoryIdentifier = FocusNotificationConstants.categoryID

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: FocusNotificationConstants.runningNotificationID,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func scheduleCompletionNotification(in seconds: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [FocusNotificationConstants.completionNotificationID])

        let content = UNMutableNotificationContent()
        content.title = "Focus complete"
        content.body = "Session finished. Nice work."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(seconds, 1)), repeats: false)
        let request = UNNotificationRequest(
            identifier: FocusNotificationConstants.completionNotificationID,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelAllFocusNotifications() async {
        center.removePendingNotificationRequests(withIdentifiers: [
            FocusNotificationConstants.runningNotificationID,
            FocusNotificationConstants.completionNotificationID
        ])
        center.removeDeliveredNotifications(withIdentifiers: [
            FocusNotificationConstants.runningNotificationID,
            FocusNotificationConstants.completionNotificationID
        ])
    }
}
