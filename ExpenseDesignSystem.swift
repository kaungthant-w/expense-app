import UIKit

// MARK: - Color Extensions
extension UIColor {
    
    // MARK: - Primary Colors
    static let expenseBackgroundColor = UIColor.systemBackground
    static let expenseCardBackground = UIColor.secondarySystemBackground
    static let expensePrimaryText = UIColor.label
    static let expenseSecondaryText = UIColor.secondaryLabel
    static let expenseAccentColor = UIColor.systemBlue
    static let expenseErrorColor = UIColor.systemRed
    
    // MARK: - Input Field Colors
    static let expenseInputBackground = UIColor.tertiarySystemBackground
    static let expenseInputBorder = UIColor.separator
    static let expenseInputText = UIColor.label
    static let expenseInputPlaceholder = UIColor.placeholderText
    
    // MARK: - Button Colors
    static let expensePrimaryButton = UIColor.systemBlue
    static let expenseSecondaryButton = UIColor.systemGray
    static let expenseDestructiveButton = UIColor.systemRed
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
