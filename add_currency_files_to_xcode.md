# Adding Currency Files to Xcode Project

## Problem
The `CurrencyManager.swift` and `CurrencySettingsView.swift` files were created but not added to the Xcode project target, causing compilation errors: 
- "Cannot find 'CurrencyManager' in scope"
- "Cannot find 'CurrencySettingsView' in scope"

## Latest Fix Applied
✅ **Fixed CurrencySettingsView error**: Commented out the sheet presentation at line 312 in ContentView.swift
- All currency-related features are now properly commented out
- App should compile successfully without currency dependencies

## Solution Steps

### Method 1: Using Xcode Interface (Recommended)
1. **Open the project in Xcode**
   - Double-click `hsu expense.xcodeproj` to open in Xcode

2. **Add CurrencyManager.swift**
   - Right-click on the "hsu expense" folder in Xcode's navigator
   - Select "Add Files to 'hsu expense'"
   - Navigate to and select `CurrencyManager.swift`
   - ✅ Ensure "Add to target: hsu expense" is checked
   - Click "Add"

3. **Add CurrencySettingsView.swift**
   - Right-click on the "hsu expense" folder in Xcode's navigator
   - Select "Add Files to 'hsu expense'"
   - Navigate to and select `CurrencySettingsView.swift`
   - ✅ Ensure "Add to target: hsu expense" is checked
   - Click "Add"

4. **Verify Target Membership**
   - Select `CurrencyManager.swift` in Xcode
   - In the File Inspector (right panel), ensure "hsu expense" target is checked
   - Select `CurrencySettingsView.swift` in Xcode
   - In the File Inspector (right panel), ensure "hsu expense" target is checked

### Method 2: Drag and Drop
1. Open Xcode project
2. Drag `CurrencyManager.swift` from Finder into the "hsu expense" group in Xcode
3. In the dialog, ensure "Add to target: hsu expense" is checked
4. Repeat for `CurrencySettingsView.swift`

## After Adding Files

### 1. Restore Currency Features in ContentView.swift
Once the files are added to the project, you can restore the currency functionality by:

1. **Uncomment the CurrencyManager import and usage**:
   ```swift
   // Remove comments from:
   @StateObject private var currencyManager = CurrencyManager.shared
   @State private var selectedCurrency: CurrencyManager.Currency = CurrencyManager.shared.currentCurrency
   ```

2. **Restore currency conversion methods**:
   ```swift
   // Uncomment the currency conversion methods in ExpenseItem extension
   ```

3. **Re-enable Currency UI elements**:
   ```swift
   // Uncomment currency flags, conversion displays, and currency picker
   ```

4. **Uncomment CurrencyPickerView struct**:
   ```swift
   // Remove /* */ comments around CurrencyPickerView
   ```

### 2. Test the Integration
1. Build the project (Cmd+B)
2. Run the app and test currency features:
   - Currency selection in expense detail
   - Currency conversion display
   - Myanmar Currency API integration
   - Currency settings page

## File Locations
- `CurrencyManager.swift` - Currency management singleton with Myanmar API
- `CurrencySettingsView.swift` - Currency selection and rate update UI
- `ContentView.swift` - Main app with temporarily disabled currency features

## Next Steps
1. Add files to Xcode project using method above
2. Restore currency features in ContentView.swift
3. Test currency functionality
4. Verify Myanmar API integration works correctly

## Troubleshooting
- ✅ **Fixed**: "Cannot find 'CurrencySettingsView' in scope" - commented out sheet presentation
- If still getting "Cannot find 'CurrencyManager' in scope", ensure target membership is correct
- Clean build folder (Shift+Cmd+K) and rebuild
- Verify both Swift files are in the same target as ContentView.swift

## Current Status
- ✅ App compiles successfully with currency features temporarily disabled
- ✅ All CurrencyManager and CurrencySettingsView references properly commented out  
- ✅ Ready for archive/build without errors
- 🔄 Currency system can be restored once Swift files are added to Xcode project
