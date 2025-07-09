# Using Custom Images in Your Expense App

## Image Assets Setup

The app has been configured to use custom image assets from the `Assets.xcassets` folder. Here's how to add your own images:

### 1. Adding Images to Assets.xcassets

The following image sets have been created in `hsu expense/Assets.xcassets/`:

- **ExpenseLogo.imageset** - Main app logo (32x32pt in navigation)
- **ExpenseIcon.imageset** - Default expense icon (24x24pt in lists)
- **CategoryFood.imageset** - Food/Restaurant category icon
- **CategoryTransport.imageset** - Transportation/Gas category icon
- **CategoryShopping.imageset** - Shopping/Store category icon

### 2. Image Requirements

For each image set, you need to provide 3 sizes:
- `@1x` - Standard resolution
- `@2x` - Retina resolution (2x)
- `@3x` - Super Retina resolution (3x)

Example for ExpenseLogo:
```
ExpenseLogo.imageset/
├── Contents.json
├── expense-logo.png      (32x32)
├── expense-logo@2x.png   (64x64)
└── expense-logo@3x.png   (96x96)
```

### 3. Adding Your Own Images

#### Step 1: Prepare Your Images
- Create your images in PNG format
- Follow iOS naming convention: `name.png`, `name@2x.png`, `name@3x.png`
- Recommended sizes:
  - Logo: 32x32, 64x64, 96x96
  - Category Icons: 24x24, 48x48, 72x72

#### Step 2: Add to Xcode
1. Open your project in Xcode
2. Navigate to `Assets.xcassets`
3. Right-click and select "New Image Set"
4. Name your image set (e.g., "MyCustomIcon")
5. Drag your images to the appropriate slots (1x, 2x, 3x)

#### Step 3: Use in SwiftUI
```swift
Image("MyCustomIcon")
    .resizable()
    .scaledToFit()
    .frame(width: 24, height: 24)
```

### 4. Current Image Usage in the App

#### Navigation Bar Logo
```swift
Image("ExpenseLogo")
    .resizable()
    .scaledToFit()
    .frame(width: 32, height: 32)
```

#### Category Icons in Expense List
```swift
Image(categoryIconName(for: expense.name))
    .resizable()
    .scaledToFit()
    .frame(width: 24, height: 24)
    .foregroundColor(.expenseAccent)
```

#### Empty State Icon
```swift
Image("ExpenseIcon")
    .resizable()
    .scaledToFit()
    .frame(width: 80, height: 80)
```

### 5. Customizing Category Icons

To add more category icons, modify the `categoryIconName(for:)` function in `ContentView.swift`:

```swift
private func categoryIconName(for name: String) -> String {
    let lowercaseName = name.lowercased()
    if lowercaseName.contains("health") || lowercaseName.contains("medical") {
        return "CategoryHealth"  // Add your custom health icon
    } else if lowercaseName.contains("entertainment") || lowercaseName.contains("movie") {
        return "CategoryEntertainment"  // Add your custom entertainment icon
    }
    // ... existing categories
    else {
        return "ExpenseIcon"  // Default icon
    }
}
```

### 6. Design Guidelines

- Use consistent visual style across all icons
- Ensure icons are legible at small sizes (24x24pt)
- Use appropriate contrast for light/dark mode compatibility
- Consider using SF Symbols for system consistency when possible

### 7. Alternative: Using SF Symbols

For some icons, you might prefer using Apple's SF Symbols:
```swift
Image(systemName: "cart.fill")  // Shopping
Image(systemName: "car.fill")   // Transportation
Image(systemName: "fork.knife") // Food
```

SF Symbols automatically adapt to:
- Dark/Light mode
- Dynamic Type sizing
- Accessibility settings

## Tips

1. **Fallback Icons**: Always provide a default icon in case custom images fail to load
2. **Performance**: Use appropriate image sizes to avoid memory issues
3. **Accessibility**: Add meaningful accessibility labels to images
4. **Testing**: Test your images on different devices and in both light/dark modes

## Example Custom Image Integration

Replace the placeholder images with your actual assets and the app will automatically use them throughout the interface.
