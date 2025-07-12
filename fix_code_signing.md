# Code Signing Issue Fix

## Problem Analysis
The error "Is a directory" occurs when the codesign tool encounters an improperly structured app bundle. Based on the build log, the issue is in this step:

```
CpResource /Users/ipromise/Desktop/Desktop/iso/ArchiveIntermediates/HSU\ expense/InstallationBuildProductsLocation/Applications/HSU\ expense.app/hsu\ expense /Users/ipromise/Desktop/Desktop/v1/expense-app/hsu\ expense
```

The build system is copying the source folder `hsu expense` directly into the app bundle, which creates an invalid structure.

## Root Cause
The issue is that there's a folder named `hsu expense` (source folder) and the target app name is also `HSU expense.app`. This creates a naming conflict where the source folder gets copied into the app bundle instead of the compiled binary.

## Solutions

### Solution 1: Clean Build and Specific Device Target
```bash
# Clean everything
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/hsu_expense-*

# Build for specific device
xcodebuild clean -project "hsu expense.xcodeproj" -scheme "HSU expense"
xcodebuild archive \
  -project "hsu expense.xcodeproj" \
  -scheme "HSU expense" \
  -destination "generic/platform=iOS" \
  -archivePath "build/hsu_expense.xcarchive" \
  -configuration Release \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES
```

### Solution 2: Fix Bundle Structure
The issue might be with the `PRODUCT_NAME` vs source folder naming. Check if we need to:

1. Rename the source folder from `hsu expense` to something else
2. Or update the PRODUCT_NAME in Xcode project settings

### Solution 3: Use Xcode IDE Instead of Command Line
Sometimes command line builds have issues that Xcode IDE doesn't. Try:

1. Open `hsu expense.xcodeproj` in Xcode
2. Select `HSU expense` scheme
3. Select "Any iOS Device" or your connected device
4. Go to Product → Archive

### Solution 4: Check for Invalid Files in Source
The build log shows it's copying the entire `hsu expense` folder. Check if there are any invalid files or symbolic links in the source folder.

### Solution 5: Export Options Configuration
Create a proper export options plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>WY3GFL6Y63</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## Immediate Action Plan

1. **First, try the clean build approach:**
   ```bash
   cd "/path/to/expense-app"
   rm -rf build/
   xcodebuild clean -project "hsu expense.xcodeproj" -scheme "HSU expense"
   ```

2. **Then try building with Xcode IDE:**
   - Open Xcode
   - Open the project
   - Product → Clean Build Folder
   - Product → Archive

3. **If that fails, check the source folder structure:**
   - Make sure there are no invalid files in `hsu expense/` folder
   - Check for any symbolic links or hidden files
   - Ensure all Swift files are properly formatted

4. **Verify code signing settings in Xcode:**
   - Project Settings → Signing & Capabilities
   - Make sure "Automatically manage signing" is checked
   - Verify the Team and Bundle Identifier are correct

## Expected Resolution
This should resolve the "Is a directory" error by ensuring the app bundle is properly structured before the codesign step.
