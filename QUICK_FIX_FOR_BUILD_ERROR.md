# URGENT: Quick Fix for Build Errors

## Problems
Your build is failing with these errors:

1. **Line 312**: `error: cannot find 'CurrencySettingsView' in scope`
2. **Line 340**: `Type 'NSNotification.Name?' has no member 'currencyChanged'`

## Quick Fix for Error 1 (Line 312)

### Step 1: Open your ContentView.swift file in Xcode
- Navigate to `/Users/ipromise/Desktop/Desktop/v1/expense-app/hsu expense/ContentView.swift`
- Go to line 312

### Step 2: Find this code around line 312:
```swift
.sheet(isPresented: $showCurrencySettings) {
    CurrencySettingsView()
}
```

### Step 3: Replace it with this (comment out the CurrencySettingsView):
```swift
// Currency settings temporarily disabled until CurrencySettingsView is added to project
// .sheet(isPresented: $showCurrencySettings) {
//     CurrencySettingsView()
// }
```

## Quick Fix for Error 2 (Line 340)

### Find this code around line 340:
```swift
// Listen for currency changes to refresh UI
NotificationCenter.default.addObserver(forName: .currencyChanged, object: nil, queue: .main) { _ in
    calculateTotal()
}
```

### Replace it with this:
```swift
// Currency change observer temporarily disabled until CurrencyManager is added
// NotificationCenter.default.addObserver(forName: .currencyChanged, object: nil, queue: .main) { _ in
//     calculateTotal()
// }
```

## Alternative Quick Fix
If you can't find the exact code above, search for `CurrencySettingsView()` in your ContentView.swift file and comment out that entire `.sheet` block.

## After the Fix
1. Save the file (Cmd+S)
2. Try building again (Cmd+B)
3. The error should be resolved

## Why This Happened
The `CurrencySettingsView.swift` file exists but isn't added to your Xcode project target, so the compiler can't find it. This fix temporarily disables the currency settings feature until you can properly add the file to your project.

## Next Steps (After successful build)
1. Add `CurrencyManager.swift` and `CurrencySettingsView.swift` to your Xcode project
2. Follow the instructions in `add_currency_files_to_xcode.md`
3. Restore the currency features

---
**Priority**: Apply this fix immediately to resolve the build error!
