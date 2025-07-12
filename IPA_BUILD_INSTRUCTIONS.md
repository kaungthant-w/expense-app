# HSU Expense IPA Build Instructions

## 📱 App Name Changes Made

### ✅ Changes Applied:
1. **App Display Name**: Updated to "HSU Expense"
   - Modified `project.pbxproj` to include `INFOPLIST_KEY_CFBundleDisplayName = "HSU Expense";`
   - Applied to both Debug and Release configurations
   
2. **IPA File Name**: Updated build script to export as "HSU Expense.ipa"
   - Modified `build_ipa.sh` to rename the exported IPA file
   - The script now automatically renames the IPA after export

### 🏗️ Build Configuration Updates:

**Project Configuration (`hsu expense.xcodeproj/project.pbxproj`):**
```
INFOPLIST_KEY_CFBundleDisplayName = "HSU Expense";
```

**Build Script (`build_ipa.sh`):**
- Added automatic IPA renaming logic
- The script will rename `hsu expense.ipa` or `HSU expense.ipa` to `HSU Expense.ipa`

## 🚀 How to Build (macOS Required)

### Prerequisites:
- macOS with Xcode installed
- Valid Apple Developer account configured
- Project opened in Xcode

### Build Steps:

1. **Open Terminal** and navigate to the project directory:
   ```bash
   cd /path/to/hsu-expense-iso-app/expense-app
   ```

2. **Make build script executable**:
   ```bash
   chmod +x build_ipa.sh
   ```

3. **Run the build script**:
   ```bash
   ./build_ipa.sh
   ```

### Expected Output:
```
📱 Building HSU Expense App
Project: hsu expense.xcodeproj
Scheme: HSU expense

Available schemes:
[List of available schemes]

🧹 Cleaning previous build...
🏗️ Archiving the app...
📦 Exporting IPA...
📝 Renaming IPA to 'HSU Expense.ipa'...
✅ IPA renamed to 'HSU Expense.ipa'
✅ IPA exported to build/ipa
```

### Output Files:
- **IPA File**: `build/ipa/HSU Expense.ipa`
- **Archive**: `build/hsu_expense.xcarchive`

## 📋 Build Script Features:

1. **Clean Build**: Removes previous build artifacts
2. **Archive Creation**: Creates `.xcarchive` for App Store submission
3. **IPA Export**: Exports development IPA
4. **Automatic Renaming**: Renames to "HSU Expense.ipa"
5. **Error Handling**: Provides detailed build progress and error messages

## 🔧 Manual Build Alternative (Using Xcode):

If the script doesn't work, you can build manually:

1. **Open Xcode**: Open `hsu expense.xcodeproj`
2. **Select Scheme**: Choose "HSU expense" scheme
3. **Archive**: Product → Archive
4. **Export**: Distribute App → Development → Export
5. **Rename**: Manually rename the exported IPA to "HSU Expense.ipa"

## 📱 App Information:

- **Display Name**: HSU Expense
- **Bundle Identifier**: expense.hsu-expense
- **Team ID**: WY3GFL6Y63
- **Deployment Target**: iOS 16.2+
- **Supported Devices**: iPhone and iPad

## 🎯 Key Changes Summary:

1. ✅ App display name changed to "HSU Expense"
2. ✅ IPA export filename changed to "HSU Expense.ipa"
3. ✅ Build script updated with automatic renaming
4. ✅ Both Debug and Release configurations updated
5. ✅ iTunes artwork integration maintained

## 🔍 Troubleshooting:

### If IPA renaming fails:
- Check the `build/ipa/` directory for available files
- The script will list available files if expected IPA is not found
- Manually rename the IPA file if needed

### If build fails:
- Ensure Xcode command line tools are installed: `xcode-select --install`
- Verify the scheme name matches: "HSU expense"
- Check signing configuration in Xcode
- Ensure all dependencies are resolved

## 📝 Notes:

- This configuration requires macOS and Xcode for building
- The current Windows environment cannot build iOS apps directly
- All changes have been applied to project configuration files
- Transfer these files to a macOS system for building

---

**Ready to build "HSU Expense.ipa" with proper app naming! 🚀**
