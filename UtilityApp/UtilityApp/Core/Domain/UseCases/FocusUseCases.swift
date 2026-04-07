import Foundation

struct FocusUseCases {
    let fetchFocusSessions: () async -> [FocusSessionItem]
    let saveFocusSession: (_ durationMinutes: Int) async -> Void
}
