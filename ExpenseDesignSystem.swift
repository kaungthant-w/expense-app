import UIKit

// MARK: - Color Extensions
extension UIColor {
    
    // MARK: - Primary Colors (matching Android design)
    static let expenseBackgroundColor = expenseCustomColor(
        light: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), // #FFFFFFFF
        dark: UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1.0) // #FF121212
    )
    static let expenseCardBackground = expenseCustomColor(
        light: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), // #FFFFFFFF
        dark: UIColor(red: 0.176, green: 0.176, blue: 0.176, alpha: 1.0) // #FF2D2D2D
    )
    static let expensePrimaryText = expenseCustomColor(
        light: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), // #FF000000
        dark: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFFFF
    )
    static let expenseSecondaryText = expenseCustomColor(
        light: UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1.0), // #FF555555
        dark: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // #FFCCCCCC
    )
    static let expenseAccentColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0) // #FF4CAF50
    static let expenseErrorColor = UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1.0) // #FFF44336
    
    // MARK: - Input Field Colors (matching Android design)
    static let expenseInputBackground = expenseCustomColor(
        light: UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1.0), // #FFF8F8F8
        dark: UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.0) // #FF383838
    )
    static let expenseInputBorder = expenseCustomColor(
        light: UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1.0), // #FFEEEEEE
        dark: UIColor(red: 0.314, green: 0.314, blue: 0.314, alpha: 1.0) // #FF505050
    )
    static let expenseInputText = expenseCustomColor(
        light: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), // #FF000000
        dark: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFFFF
    )
    static let expenseInputPlaceholder = expenseCustomColor(
        light: UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1.0), // #FF555555
        dark: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // #FFCCCCCC
    )
    
    // MARK: - Button Colors (matching Android design)
    static let expensePrimaryButton = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0) // #FF4CAF50
    static let expenseSecondaryButton = expenseCustomColor(
        light: UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0), // #FFE0E0E0
        dark: UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 1.0) // #FF404040
    )
    static let expenseDestructiveButton = UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1.0) // #FFF44336
    static let expenseButtonText = UIColor.white
    
    // MARK: - Shadow Colors
    static let expenseCardShadow = UIColor.black.withAlphaComponent(0.1)
    
    // MARK: - Custom Colors for Branding (if needed)
    static func expenseCustomColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}

// MARK: - Font Extensions
extension UIFont {
    
    // MARK: - Headers
    static let expenseTitleFont = UIFont.boldSystemFont(ofSize: 16)
    static let expenseLabelFont = UIFont.systemFont(ofSize: 12)
    static let expenseSubtitleFont = UIFont.systemFont(ofSize: 14)
    
    // MARK: - Content
    static let expenseInputFont = UIFont.boldSystemFont(ofSize: 18)
    static let expenseDescriptionFont = UIFont.systemFont(ofSize: 16)
    static let expenseButtonFont = UIFont.boldSystemFont(ofSize: 12)
    static let expenseCaptionFont = UIFont.systemFont(ofSize: 10)
    
    // MARK: - Dynamic Type Support
    static func expenseFont(style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}

// MARK: - Spacing Constants
struct ExpenseSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let xLarge: CGFloat = 24
    static let xxLarge: CGFloat = 32
    
    // Component specific spacing
    static let cardPadding: CGFloat = 20
    static let cardMargin: CGFloat = 24
    static let fieldSpacing: CGFloat = 20
    static let buttonHeight: CGFloat = 56
    static let inputHeight: CGFloat = 50
    static let headerHeight: CGFloat = 48
    
    // Corner radius
    static let cardCornerRadius: CGFloat = 20
    static let inputCornerRadius: CGFloat = 8
    static let buttonCornerRadius: CGFloat = 12
}

// MARK: - Animation Constants
struct ExpenseAnimation {
    static let shortDuration: TimeInterval = 0.1
    static let mediumDuration: TimeInterval = 0.3
    static let longDuration: TimeInterval = 0.6
    
    static let buttonScaleDown: CGFloat = 0.95
    static let buttonScaleUp: CGFloat = 1.0
    
    static let springDamping: CGFloat = 0.7
    static let springVelocity: CGFloat = 0.3
}

// MARK: - Shadow Configuration
struct ExpenseShadow {
    static let cardShadowOffset = CGSize(width: 0, height: 2)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowOpacity: Float = 0.1
    
    static let buttonShadowOffset = CGSize(width: 0, height: 1)
    static let buttonShadowRadius: CGFloat = 4
    static let buttonShadowOpacity: Float = 0.2
}

// MARK: - Layout Constants
struct ExpenseLayout {
    // Device specific margins
    static func horizontalMargin(for traitCollection: UITraitCollection) -> CGFloat {
        switch traitCollection.horizontalSizeClass {
        case .compact:
            return 16
        case .regular:
            return 32
        default:
            return 16
        }
    }
    
    static func contentMaxWidth(for traitCollection: UITraitCollection) -> CGFloat {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return 600 // iPad max width
        default:
            return .greatestFiniteMagnitude
        }
    }
    
    // Input validation
    static let maxNameLength = 35
    static let maxDescriptionLength = 350
    static let maxPriceDigitsBeforeDecimal = 12
    static let maxPriceDigitsAfterDecimal = 2
}
