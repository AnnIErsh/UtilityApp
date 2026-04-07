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
        }
    }

    private var timer: Timer?
    private let focusUseCases: FocusUseCases

    init(focusUseCases: FocusUseCases) {
        self.focusUseCases = focusUseCases
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
    }

    var progress: Double {
        let total = max(selectedMinutes * 60, 1)
        return 1 - (Double(remainingSeconds) / Double(total))
    }

    private func start() {
        guard !isRunning else { return }
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [self] in
                self.handleTimerTick()
            }
        }
    }

    private func handleTimerTick() {
        guard isRunning else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            pause()
            let completedMinutes = selectedMinutes
            Task {
                await focusUseCases.saveFocusSession(completedMinutes)
            }
            remainingSeconds = selectedMinutes * 60
        }
    }

    private func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}
