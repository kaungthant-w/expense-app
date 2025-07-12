#!/bin/bash
# Clean build script for HSU Expense App to fix code signing issues

echo "🔧 HSU Expense App - Clean Build Fix"
echo "==================================="

# Check if we're in the right directory
if [ ! -d "hsu expense.xcodeproj" ]; then
    echo "❌ Error: hsu expense.xcodeproj not found"
    echo "Please run this script from the expense-app directory"
    exit 1
fi

echo "✅ Found Xcode project"

# Step 1: Clean everything thoroughly
echo ""
echo "🧹 Step 1: Cleaning all build artifacts..."
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/hsu*expense*
echo "✅ Cleaned build artifacts and derived data"

# Step 2: Clean Xcode project
echo ""
echo "🧹 Step 2: Cleaning Xcode project..."
xcodebuild clean -project "hsu expense.xcodeproj" -scheme "HSU expense"
echo "✅ Cleaned Xcode project"

# Step 3: Archive with proper settings
echo ""
echo "🏗️  Step 3: Creating archive with fixed settings..."
xcodebuild archive \
  -project "hsu expense.xcodeproj" \
  -scheme "HSU expense" \
  -destination "generic/platform=iOS" \
  -archivePath "build/hsu_expense_fixed.xcarchive" \
  -configuration Release \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES \
  -allowProvisioningUpdates \
  -quiet

# Check if archive succeeded
if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully!"
    echo ""
    echo "📦 Archive location: build/hsu_expense_fixed.xcarchive"
    echo ""
    echo "🚀 Next steps:"
    echo "1. You can now export the IPA using:"
    echo "   xcodebuild -exportArchive -archivePath build/hsu_expense_fixed.xcarchive -exportPath build/ipa -exportOptionsPlist exportOptionsDiawi.plist"
    echo ""
    echo "2. Or open the archive in Xcode Organizer for distribution"
else
    echo "❌ Archive failed. Please try using Xcode IDE:"
    echo ""
    echo "🎯 Recommended: Use Xcode IDE instead"
    echo "1. Open 'hsu expense.xcodeproj' in Xcode"
    echo "2. Select 'HSU expense' scheme"
    echo "3. Select 'Any iOS Device' as destination"
    echo "4. Go to Product → Clean Build Folder"
    echo "5. Go to Product → Archive"
    echo ""
    echo "💡 The Xcode IDE often resolves code signing issues that"
    echo "   command line tools struggle with due to better bundle"
    echo "   structure management."
fi
