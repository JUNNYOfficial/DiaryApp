import SwiftUI

struct AppTheme {
    let primaryBlue: Color
    let lightBlue: Color
    let backgroundWhite: Color
    let cardBackground: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentBlue: Color
    
    static let `default` = AppTheme(
        primaryBlue: Color(red: 0.20, green: 0.50, blue: 0.85),
        lightBlue: Color(red: 0.90, green: 0.95, blue: 1.00),
        backgroundWhite: Color(red: 0.98, green: 0.99, blue: 1.00),
        cardBackground: Color.white,
        textPrimary: Color(red: 0.15, green: 0.20, blue: 0.30),
        textSecondary: Color(red: 0.45, green: 0.50, blue: 0.60),
        accentBlue: Color(red: 0.25, green: 0.55, blue: 0.90)
    )
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.default
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
