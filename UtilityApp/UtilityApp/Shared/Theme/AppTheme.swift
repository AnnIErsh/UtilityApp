import SwiftUI
import UIKit

struct AppTheme {
    static let primary = Color.dynamic(light: "0F4C81", dark: "6EA7D8")
    static let primaryDeep = Color.dynamic(light: "0A2F52", dark: "9CC3E6")
    static let accent = Color.dynamic(light: "16A34A", dark: "34D399")
    static let warning = Color.dynamic(light: "F59E0B", dark: "FBBF24")

    static let textPrimary = Color.dynamic(light: "0E1A2A", dark: "E5EEF8")
    static let textSecondary = Color.dynamic(light: "44566C", dark: "A7BACF")

    static let background = Color.dynamic(light: "EEF4FA", dark: "0B1420")
    static let card = Color.dynamic(light: "FFFFFF", dark: "162232", alphaLight: 0.92, alphaDark: 0.92)

    static let cardStroke = Color.dynamic(light: "FFFFFF", dark: "2A3B52", alphaLight: 0.75, alphaDark: 0.90)
    static let cardShadow = Color.dynamic(light: "0A2F52", dark: "000000", alphaLight: 0.10, alphaDark: 0.35)

    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [
                primary.opacity(0.12),
                accent.opacity(0.10),
                background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var splashGradient: LinearGradient {
        LinearGradient(
            colors: [primary.opacity(0.95), accent.opacity(0.90)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum AppTypography {
    static func hero(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func title(_ size: CGFloat = 30) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func section(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

extension Color {
    static func dynamic(light: String, dark: String, alphaLight: CGFloat = 1, alphaDark: CGFloat = 1) -> Color {
        Color(
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(hex: dark, alpha: alphaDark)
                }
                return UIColor(hex: light, alpha: alphaLight)
            }
        )
    }

    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
