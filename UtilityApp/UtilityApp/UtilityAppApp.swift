import SwiftUI
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupFocusNotificationCategory()
        return true
    }

    private func setupFocusNotificationCategory() {
        let pauseAction = UNNotificationAction(
            identifier: FocusNotificationConstants.pauseActionID,
            title: "Pause",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: FocusNotificationConstants.categoryID,
            actions: [pauseAction],
            intentIdentifiers: [],
            options: []
        )
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == FocusNotificationConstants.pauseActionID {
            UserDefaults.standard.set(true, forKey: FocusNotificationConstants.pauseRequestedKey)
        }
        if response.notification.request.identifier == FocusNotificationConstants.completionNotificationID {
            UserDefaults.standard.set(true, forKey: FocusNotificationConstants.completionTappedKey)
        }
        completionHandler()
    }
}

@main
struct UtilityAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
