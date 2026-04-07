import SwiftUI

struct AppTheme {
    static let primary = Color(hex: "0F4C81")
    static let primaryDeep = Color(hex: "0A2F52")
    static let accent = Color(hex: "16A34A")
    static let warning = Color(hex: "F59E0B")

    static let textPrimary = Color(hex: "0E1A2A")
    static let textSecondary = Color(hex: "44566C")

    static let background = Color(hex: "EEF4FA")
    static let card = Color.white.opacity(0.92)

    static let cardStroke = Color.white.opacity(0.75)
    static let cardShadow = Color(hex: "0A2F52").opacity(0.10)

    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [
                primary.opacity(0.10),
                accent.opacity(0.08),
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
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
