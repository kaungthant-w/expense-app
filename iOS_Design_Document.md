# iOS App Design Document - Expense Detail Screen

## Overview
This document outlines the iOS implementation design for the Expense Detail screen, translating the Android XML layout to iOS Swift/UIKit components.

## Screen Architecture

### Navigation Structure
- **UINavigationController** with custom back button
- **Modal presentation** or **Push navigation** from expense list
- **Custom navigation bar** with title and back button

### Layout Framework
- **UIScrollView** as root container (equivalent to Android ScrollView)
- **UIStackView** for vertical layout organization
- **Auto Layout** constraints for responsive design
- **Safe Area** compliance for modern iOS devices

## UI Component Mapping

### 1. Header Section
**Android Equivalent**: LinearLayout with ImageButton + TextView

**iOS Implementation**:
```swift
// Custom Navigation Bar
class ExpenseDetailViewController: UIViewController {
    private let headerStackView = UIStackView()
    private let backButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
}
```

**Design Specifications**:
- **Back Button**: 48x48pt custom button with arrow icon
- **Title**: Bold, 16pt system font
- **Layout**: Horizontal stack with leading back button, trailing title
- **Margins**: 16pt horizontal, 30pt bottom

### 2. Main Content Card
**Android Equivalent**: CardView with LinearLayout

**iOS Implementation**:
```swift
private let contentCardView = UIView()
private let cardStackView = UIStackView()
```

**Design Specifications**:
- **Card Style**: Rounded corners (20pt radius), subtle shadow
- **Background**: System background color with elevation effect
- **Padding**: 20pt internal padding
- **Margins**: 24pt bottom margin

### 3. Form Fields

#### Name Field
**Android**: EditText with label
**iOS**: UITextField with UILabel

```swift
private let nameLabel = UILabel()
private let nameTextField = UITextField()
```

**Specifications**:
- **Label**: "💼 Name", 12pt secondary color
- **TextField**: 18pt bold text, 35 character limit
- **Background**: Rounded input style
- **Margins**: 8pt label-to-field, 20pt bottom

#### Price Field
**Android**: EditText with numberDecimal input
**iOS**: UITextField with number keyboard

```swift
private let priceLabel = UILabel()
private let priceTextField = UITextField()
```

**Specifications**:
- **Label**: "💵 Price", 12pt secondary color
- **TextField**: 18pt bold, accent color text
- **Input**: Decimal number keyboard
- **Validation**: 12 digits before decimal, 2 after

#### Description Field
**Android**: EditText with multiline
**iOS**: UITextView

```swift
private let descriptionLabel = UILabel()
private let descriptionTextView = UITextView()
```

**Specifications**:
- **Label**: "📝 Description", 12pt secondary color
- **TextView**: 16pt text, 3 line minimum height
- **Scrolling**: Vertical scrolling enabled
- **Limit**: 350 characters maximum

#### Date & Time Fields
**Android**: Two EditText in horizontal LinearLayout
**iOS**: Two UITextField in horizontal UIStackView

```swift
private let dateTimeStackView = UIStackView()
private let dateLabel = UILabel()
private let dateTextField = UITextField()
private let timeLabel = UILabel()
private let timeTextField = UITextField()
```

**Specifications**:
- **Layout**: Equal width horizontal distribution
- **Date Picker**: UIDatePicker integration
- **Time Picker**: UIDatePicker in time mode
- **Format**: DD/MM/YYYY and HH:MM

### 4. Action Buttons
**Android**: Two Buttons in horizontal LinearLayout
**iOS**: Two UIButton in horizontal UIStackView

```swift
private let buttonStackView = UIStackView()
private let saveButton = UIButton(type: .system)
private let deleteButton = UIButton(type: .system)
```

**Specifications**:
- **Layout**: Equal width, 56pt height
- **Save Button**: Primary color background, white text
- **Delete Button**: Error color background, white text
- **Typography**: 12pt bold text
- **Margins**: 8pt between buttons, 20pt top margin

## Color Scheme & Theming

### Dynamic Colors (iOS 13+)
```swift
// Primary Colors
static let backgroundColor = UIColor.systemBackground
static let cardBackground = UIColor.secondarySystemBackground
static let primaryText = UIColor.label
static let secondaryText = UIColor.secondaryLabel
static let accentColor = UIColor.systemBlue
static let errorColor = UIColor.systemRed

// Input Field Colors
static let inputBackground = UIColor.tertiarySystemBackground
static let inputBorder = UIColor.separator
```

### Dark Mode Support
- Automatic color adaptation using semantic colors
- Custom asset colors for brand-specific elements
- Dynamic shadow adjustments for card elevation

## Typography System

### Font Hierarchy
```swift
// Headers
static let titleFont = UIFont.boldSystemFont(ofSize: 16)
static let labelFont = UIFont.systemFont(ofSize: 12)

// Content
static let inputFont = UIFont.boldSystemFont(ofSize: 18)
static let descriptionFont = UIFont.systemFont(ofSize: 16)
static let buttonFont = UIFont.boldSystemFont(ofSize: 12)
```

## Responsive Design

### Device Adaptations
- **iPhone SE**: Compact vertical spacing
- **iPhone Standard**: Standard 16pt margins
- **iPhone Plus/Max**: Expanded margins (20pt)
- **iPad**: Centered content with max width constraints

### Orientation Support
- **Portrait**: Primary layout
- **Landscape**: Adjusted spacing and field arrangements

## Accessibility Features

### VoiceOver Support
```swift
// Accessibility labels
nameTextField.accessibilityLabel = "Expense name"
priceTextField.accessibilityLabel = "Expense price"
descriptionTextView.accessibilityLabel = "Expense description"
dateTextField.accessibilityLabel = "Expense date"
timeTextField.accessibilityLabel = "Expense time"

// Button accessibility
saveButton.accessibilityLabel = "Save expense"
deleteButton.accessibilityLabel = "Delete expense"
```

### Dynamic Type Support
- All text elements support Dynamic Type scaling
- Layout adjustments for larger accessibility fonts
- Minimum touch target sizes (44x44pt)

## Implementation Structure

### View Controller Architecture
```swift
class ExpenseDetailViewController: UIViewController {
    // MARK: - Properties
    private var expense: Expense?
    private var isNewExpense: Bool = false
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        configureForCurrentExpense()
    }
    
    // MARK: - Setup Methods
    private func setupUI() { }
    private func setupConstraints() { }
    private func setupActions() { }
    private func configureForCurrentExpense() { }
}
```

### Data Management
```swift
struct Expense {
    let id: UUID
    var name: String
    var price: Decimal
    var description: String
    var date: Date
    var time: Date
    var currency: String
}

protocol ExpenseDetailDelegate: AnyObject {
    func expenseDetailDidSave(_ expense: Expense)
    func expenseDetailDidDelete(_ expenseId: UUID)
}
```

## Animation & Transitions

### Screen Transitions
- **Push Animation**: Default navigation controller transition
- **Modal Presentation**: Sheet style for iOS 13+
- **Dismissal**: Swipe to dismiss support

### Field Interactions
- **Picker Presentation**: Smooth slide-up animation
- **Validation Feedback**: Shake animation for errors
- **Button Press**: Scale feedback (0.95 scale)

### Loading States
- **Save Operation**: Button loading spinner
- **Data Loading**: Skeleton view placeholders

## Localization Support

### String Externalization
```swift
// Localizable.strings
"expense_detail_title" = "Expense Details";
"add_expense_title" = "Add Expense";
"edit_expense_title" = "Edit Expense";
"name_label" = "💼 Name";
"price_label" = "💵 Price";
"description_label" = "📝 Description";
"date_label" = "📅 Date";
"time_label" = "🕐 Time";
"save_button" = "💾 Save";
"delete_button" = "🗑️ Delete";
```

### Right-to-Left Support
- Leading/trailing constraints instead of left/right
- Natural text alignment
- Semantic content attribute configuration

## Testing Strategy

### Unit Tests
- Input validation logic
- Data model operations
- Currency formatting

### UI Tests
- Form field interactions
- Button tap responses
- Navigation flow validation

### Accessibility Tests
- VoiceOver navigation
- Dynamic Type scaling
- High contrast mode compatibility

## Performance Considerations

### Memory Management
- Weak delegate references
- Proper view controller lifecycle
- Image optimization for icons

### Smooth Scrolling
- Efficient Auto Layout constraints
- Minimal view hierarchy depth
- Optimized table view cells if using lists

## Implementation Timeline

### Phase 1: Basic UI (Week 1)
- Layout structure and constraints
- Basic form fields implementation
- Navigation setup

### Phase 2: Functionality (Week 2)
- Data binding and validation
- Picker implementations
- Save/delete operations

### Phase 3: Polish (Week 3)
- Animations and transitions
- Accessibility enhancements
- Testing and bug fixes

### Phase 4: Localization (Week 4)
- Multi-language support
- RTL layout support
- Final testing and deployment

## Dependencies

### iOS Framework Requirements
- **Minimum iOS Version**: iOS 13.0
- **Core Frameworks**: UIKit, Foundation
- **Additional**: Combine (for reactive programming)

### Third-Party Libraries (Optional)
- **SnapKit**: For programmatic Auto Layout
- **IQKeyboardManager**: Keyboard handling
- **SwiftDate**: Date manipulation utilities

This design document provides a comprehensive blueprint for implementing the expense detail screen in iOS, maintaining visual and functional parity with the Android version while following iOS design principles and best practices.
