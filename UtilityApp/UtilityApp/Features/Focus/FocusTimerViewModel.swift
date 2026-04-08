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
    }

    init(focusUseCases: FocusUseCases, storage: UserDefaults = .standard) {
        self.focusUseCases = focusUseCases
        self.storage = storage
        restoreState()
        refreshStatusText()
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

        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        startTimerIfNeeded()
        refreshFromClock()
        persistState()
        refreshStatusText()
    }

    func handleSceneDidBecomeActive() {
        if isRunning {
            refreshFromClock()
            startTimerIfNeeded()
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
        pause(clearProgress: true)
        let completedMinutes = selectedMinutes
        Task {
            await focusUseCases.saveFocusSession(completedMinutes)
        }
        remainingSeconds = selectedMinutes * 60
        persistState()
        refreshStatusText()
    }

    private func pause(clearProgress: Bool = false) {
        isRunning = false
        timer?.invalidate()
        timer = nil
        endDate = nil

        if clearProgress {
            remainingSeconds = selectedMinutes * 60
            storage.removeObject(forKey: StorageKeys.endDate)
        } else {
            storage.removeObject(forKey: StorageKeys.endDate)
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

        let wasRunning = storage.bool(forKey: StorageKeys.isRunning)
        let storedEndDate = storage.object(forKey: StorageKeys.endDate) as? Date

        if wasRunning, let storedEndDate {
            endDate = storedEndDate
            isRunning = true
            refreshFromClock()
            if isRunning {
                startTimerIfNeeded()
            }
        } else {
            isRunning = false
            endDate = nil
        }
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
}
