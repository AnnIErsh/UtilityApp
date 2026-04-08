import Combine
import Foundation

@MainActor
final class FocusTimerViewModel: ObservableObject {
    @Published var remainingSeconds: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var selectedMinutes: Int = 25 {
        didSet {
            if isRunning {
                if selectedMinutes != oldValue {
                    selectedMinutes = oldValue
                }
                return
            }
            remainingSeconds = selectedMinutes * 60
            persistState()
            refreshStatusText()
        }
    }
    @Published private(set) var statusText: String = "Ready to focus"

    private var timer: Timer?
    private var endDate: Date?
    private let focusUseCases: FocusUseCases
    private let storage: UserDefaults

    private enum StorageKeys {
        static let remainingSeconds = "focus.timer.remainingSeconds"
        static let selectedMinutes = "focus.timer.selectedMinutes"
        static let isRunning = "focus.timer.isRunning"
        static let endDate = "focus.timer.endDate"
        static let isPaused = "focus.timer.isPaused"
        static let pausedRemainingSeconds = "focus.timer.pausedRemainingSeconds"
        static let pendingSessionID = "focus.timer.pendingSessionID"
        static let pendingSessionEndDate = "focus.timer.pendingSessionEndDate"
        static let pendingSessionDuration = "focus.timer.pendingSessionDuration"
        static let lastSavedPendingSessionID = "focus.timer.lastSavedPendingSessionID"
    }

    init(focusUseCases: FocusUseCases, storage: UserDefaults = .standard) {
        self.focusUseCases = focusUseCases
        self.storage = storage
        restoreState()
        restoreFromPendingSessionIfNeeded()
        refreshStatusText()
        Task {
            await focusUseCases.requestNotificationAccess()
            await reconcilePendingCompletedSessionIfNeeded()
        }
    }

    deinit {
        timer?.invalidate()
    }

    func startPause() {
        isRunning ? pause() : start()
    }

    func reset() {
        pause()
        remainingSeconds = selectedMinutes * 60
        persistState()
        refreshStatusText()
    }

    var progress: Double {
        let total = max(selectedMinutes * 60, 1)
        return 1 - (Double(remainingSeconds) / Double(total))
    }

    private func start() {
        guard !isRunning else { return }
        guard remainingSeconds > 0 else { return }

        clearPausedState()
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        startTimerIfNeeded()
        refreshFromClock()
        persistState()
        refreshStatusText()
        storePendingSession(
            id: UUID().uuidString,
            endDate: endDate ?? Date(),
            durationMinutes: selectedMinutes
        )
        let secondsToFinish = remainingSeconds
        Task {
            await focusUseCases.scheduleCompletionNotification(secondsToFinish)
        }
    }

    func handleSceneDidBecomeActive() {
        Task {
            await reconcilePendingCompletedSessionIfNeeded()
        }
        restoreFromPendingSessionIfNeeded()
        if handleCompletionTapIfNeeded() {
            return
        }
        handlePauseActionIfNeeded()
        restoreRunningStateFromEndDateIfNeeded()
        if isRunning {
            refreshFromClock()
            startTimerIfNeeded()
        }
    }

    func handleSceneDidEnterBackground() {
        guard isRunning else { return }
        let secondsLeft = remainingSeconds
        Task {
            await focusUseCases.scheduleRunningNotification(secondsLeft)
        }
    }

    private func startTimerIfNeeded() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [self] in
                self.refreshFromClock()
            }
        }
        timer?.tolerance = 0.2
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func refreshFromClock() {
        guard isRunning else { return }
        guard let endDate else { return }

        let secondsLeft = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
        remainingSeconds = secondsLeft
        refreshStatusText()

        if secondsLeft == 0 {
            finishSession()
        }
    }

    private func finishSession() {
        pause(clearProgress: true, clearPendingData: false)
        Task {
            await savePendingSessionIfNeeded()
            await focusUseCases.cancelFocusNotifications()
        }
        clearPendingSession()
        clearPausedState()
        remainingSeconds = selectedMinutes * 60
        persistState()
        refreshStatusText()
        Task {
            await focusUseCases.cancelFocusNotifications()
        }
    }

    private func pause(clearProgress: Bool = false, clearPendingData: Bool = true) {
        isRunning = false
        timer?.invalidate()
        timer = nil
        endDate = nil

        if clearProgress {
            remainingSeconds = selectedMinutes * 60
            storage.removeObject(forKey: StorageKeys.endDate)
            clearPausedState()
        } else {
            storage.removeObject(forKey: StorageKeys.endDate)
            storage.set(true, forKey: StorageKeys.isPaused)
            storage.set(remainingSeconds, forKey: StorageKeys.pausedRemainingSeconds)
        }

        if clearPendingData {
            clearPendingSession()
        }

        persistState()
        refreshStatusText()
    }

    private func restoreState() {
        let storedMinutes = storage.integer(forKey: StorageKeys.selectedMinutes)
        if storedMinutes > 0 {
            selectedMinutes = storedMinutes
        }

        let storedRemaining = storage.integer(forKey: StorageKeys.remainingSeconds)
        if storedRemaining > 0 {
            remainingSeconds = storedRemaining
        } else {
            remainingSeconds = selectedMinutes * 60
        }

        let storedEndDate = storage.object(forKey: StorageKeys.endDate) as? Date

        if let storedEndDate, storedEndDate > Date() {
            endDate = storedEndDate
            isRunning = true
            refreshFromClock()
            if isRunning {
                startTimerIfNeeded()
            }
        } else {
            isRunning = false
            endDate = nil
            if storage.bool(forKey: StorageKeys.isPaused) {
                let pausedRemaining = storage.integer(forKey: StorageKeys.pausedRemainingSeconds)
                remainingSeconds = max(pausedRemaining, 1)
            } else if storedRemaining <= 0 {
                remainingSeconds = selectedMinutes * 60
            }
        }

        restorePausedStateFromPendingSessionIfNeeded()
    }

    private func persistState() {
        storage.set(remainingSeconds, forKey: StorageKeys.remainingSeconds)
        storage.set(selectedMinutes, forKey: StorageKeys.selectedMinutes)
        storage.set(isRunning, forKey: StorageKeys.isRunning)
        storage.set(endDate, forKey: StorageKeys.endDate)
    }

    private func refreshStatusText() {
        if isRunning {
            statusText = "Running in background"
            return
        }
        if remainingSeconds < selectedMinutes * 60 {
            statusText = "Paused"
            return
        }
        statusText = "Ready to focus"
    }

    private func handlePauseActionIfNeeded() {
        let pauseRequested = storage.bool(forKey: FocusNotificationConstants.pauseRequestedKey)
        guard pauseRequested else { return }
        storage.set(false, forKey: FocusNotificationConstants.pauseRequestedKey)
        if isRunning {
            pause()
        }
    }

    private func restoreRunningStateFromEndDateIfNeeded() {
        guard !isRunning else { return }
        guard let storedEndDate = storage.object(forKey: StorageKeys.endDate) as? Date else { return }
        guard storedEndDate > Date() else { return }

        endDate = storedEndDate
        isRunning = true
    }

    private func handleCompletionTapIfNeeded() -> Bool {
        let completionTapped = storage.bool(forKey: FocusNotificationConstants.completionTappedKey)
        guard completionTapped else { return false }
        storage.set(false, forKey: FocusNotificationConstants.completionTappedKey)

        if isRunning {
            finishSession()
            return true
        }

        if let endDate, endDate <= Date() {
            Task {
                await savePendingSessionIfNeeded()
                await focusUseCases.cancelFocusNotifications()
            }
            isRunning = false
            self.endDate = nil
            remainingSeconds = selectedMinutes * 60
            persistState()
            refreshStatusText()
            return true
        }

        return false
    }

    private func storePendingSession(id: String, endDate: Date, durationMinutes: Int) {
        storage.set(id, forKey: StorageKeys.pendingSessionID)
        storage.set(endDate, forKey: StorageKeys.pendingSessionEndDate)
        storage.set(durationMinutes, forKey: StorageKeys.pendingSessionDuration)
    }

    private func clearPendingSession() {
        storage.removeObject(forKey: StorageKeys.pendingSessionID)
        storage.removeObject(forKey: StorageKeys.pendingSessionEndDate)
        storage.removeObject(forKey: StorageKeys.pendingSessionDuration)
    }

    private func savePendingSessionIfNeeded() async {
        guard let pendingID = storage.string(forKey: StorageKeys.pendingSessionID) else { return }
        let lastSavedID = storage.string(forKey: StorageKeys.lastSavedPendingSessionID)
        guard pendingID != lastSavedID else {
            clearPendingSession()
            return
        }

        let pendingDuration = storage.integer(forKey: StorageKeys.pendingSessionDuration)
        let durationToSave = max(pendingDuration, selectedMinutes, 1)
        await focusUseCases.saveFocusSession(durationToSave)
        storage.set(pendingID, forKey: StorageKeys.lastSavedPendingSessionID)
        clearPendingSession()
    }

    private func reconcilePendingCompletedSessionIfNeeded() async {
        guard let pendingEndDate = storage.object(forKey: StorageKeys.pendingSessionEndDate) as? Date else { return }
        guard Date() >= pendingEndDate else { return }
        await savePendingSessionIfNeeded()
    }

    private func restoreFromPendingSessionIfNeeded() {
        guard !isRunning else { return }
        guard let pendingEndDate = storage.object(forKey: StorageKeys.pendingSessionEndDate) as? Date else { return }
        guard pendingEndDate > Date() else { return }

        let pendingDuration = storage.integer(forKey: StorageKeys.pendingSessionDuration)
        if pendingDuration > 0 {
            selectedMinutes = pendingDuration
        }

        endDate = pendingEndDate
        remainingSeconds = max(Int(ceil(pendingEndDate.timeIntervalSinceNow)), 1)
        isRunning = true
        persistState()
        startTimerIfNeeded()
    }

    private func restorePausedStateFromPendingSessionIfNeeded() {
        guard !isRunning else { return }
        guard !storage.bool(forKey: StorageKeys.isPaused) else { return }
        guard let pendingEndDate = storage.object(forKey: StorageKeys.pendingSessionEndDate) as? Date else { return }
        guard pendingEndDate > Date() else { return }

        let pendingDuration = storage.integer(forKey: StorageKeys.pendingSessionDuration)
        if pendingDuration > 0 {
            selectedMinutes = pendingDuration
        }

        if let storedEndDate = storage.object(forKey: StorageKeys.endDate) as? Date, storedEndDate > Date() {
            return
        }

        let secondsLeft = max(Int(ceil(pendingEndDate.timeIntervalSinceNow)), 1)
        remainingSeconds = secondsLeft
        endDate = nil
        persistState()
        refreshStatusText()
    }

    private func clearPausedState() {
        storage.set(false, forKey: StorageKeys.isPaused)
        storage.removeObject(forKey: StorageKeys.pausedRemainingSeconds)
    }
}
