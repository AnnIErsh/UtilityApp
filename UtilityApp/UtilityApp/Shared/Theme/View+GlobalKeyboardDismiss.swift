import SwiftUI
import UIKit

extension View {
    func dismissKeyboardOnGlobalTap() -> some View {
        background(WindowKeyboardDismissInstaller())
    }
}

private struct WindowKeyboardDismissInstaller: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WindowObserverView {
        let view = WindowObserverView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.onWindowChange = { [weak coordinator = context.coordinator] window in
            coordinator?.installIfNeeded(on: window)
        }
        return view
    }

    func updateUIView(_ uiView: WindowObserverView, context: Context) {
        uiView.onWindowChange = { [weak coordinator = context.coordinator] window in
            coordinator?.installIfNeeded(on: window)
        }
        context.coordinator.installIfNeeded(on: uiView.window)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var window: UIWindow?
        private var tapRecognizer: UITapGestureRecognizer?

        func installIfNeeded(on newWindow: UIWindow?) {
            guard let newWindow else { return }
            guard window !== newWindow else { return }

            if let tapRecognizer, let window {
                window.removeGestureRecognizer(tapRecognizer)
            }

            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            recognizer.requiresExclusiveTouchType = false

            newWindow.addGestureRecognizer(recognizer)
            window = newWindow
            tapRecognizer = recognizer
        }

        @objc
        private func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard recognizer.state == .ended else { return }
            window?.endEditing(true)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard let touchedView = touch.view else { return true }
            return touchedView.closestTextInputView == nil
        }
    }
}

private final class WindowObserverView: UIView {
    var onWindowChange: ((UIWindow?) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onWindowChange?(window)
    }
}

private extension UIView {
    var closestTextInputView: UIView? {
        var current: UIView? = self
        while let view = current {
            if view is UITextField || view is UITextView {
                return view
            }
            current = view.superview
        }
        return nil
    }
}
