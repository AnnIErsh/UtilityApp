import SwiftUI

@main
struct UtilityAppApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
