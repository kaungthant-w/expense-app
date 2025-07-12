#!/bin/bash
# build_for_appstore.sh - Build and prepare IPA for App Store distribution

set -e

PROJECT="hsu expense.xcodeproj"
SCHEME="HSU expense"
ARCHIVE_PATH="build/hsu_expense_appstore.xcarchive"
EXPORT_PATH="build/appstore"
EXPORT_OPTIONS="exportOptionsAppStore.plist"

echo "🏪 Building HSU Expense for App Store"
echo "====================================="
echo "Project: $PROJECT"
echo "Scheme: $SCHEME"
echo "Export Options: $EXPORT_OPTIONS"
echo "Bundle ID: expense.hsu-expense"
echo ""

# Check if we have the required files
if [ ! -f "$PROJECT/project.pbxproj" ]; then
    echo "❌ Error: Xcode project not found!"
    exit 1
fi

if [ ! -f "$EXPORT_OPTIONS" ]; then
    echo "❌ Error: App Store export options file not found!"
    exit 1
fi

# List available schemes for debugging
echo "📋 Available schemes:"
xcodebuild -project "$PROJECT" -list | grep -A 10 "Schemes:"

echo ""
echo "🧹 Cleaning previous builds..."
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
mkdir -p build

echo ""
echo "🏗️  Archiving for App Store..."
# Archive the app for App Store
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    archive

echo ""
echo "📦 Exporting for App Store..."
# Export for App Store
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

echo ""
echo "📝 Organizing App Store files..."
# The App Store export creates a different file structure
if [ -f "$EXPORT_PATH/HSU expense.ipa" ]; then
    echo "✅ App Store IPA created: $EXPORT_PATH/HSU expense.ipa"
elif [ -f "$EXPORT_PATH/hsu expense.ipa" ]; then
    mv "$EXPORT_PATH/hsu expense.ipa" "$EXPORT_PATH/HSU expense.ipa"
    echo "✅ App Store IPA created: $EXPORT_PATH/HSU expense.ipa"
else
    echo "⚠️  Looking for IPA files in export directory..."
    find "$EXPORT_PATH" -name "*.ipa" -exec mv {} "$EXPORT_PATH/HSU expense.ipa" \;
fi

# Verify the final IPA exists
if [ -f "$EXPORT_PATH/HSU expense.ipa" ]; then
    echo ""
    echo "✅ APP STORE BUILD SUCCESSFUL!"
    echo "=============================="
    echo "📱 IPA File: $EXPORT_PATH/HSU expense.ipa"
    echo "📊 File Size: $(du -h "$EXPORT_PATH/HSU expense.ipa" | cut -f1)"
    echo ""
    echo "🏪 Ready for App Store Upload!"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Create App Store Connect record"
    echo "   2. Upload via Xcode or Application Loader"
    echo "   3. Fill in App Store metadata"
    echo "   4. Submit for App Store Review"
    echo ""
    echo "📝 App Information Summary:"
    echo "   • App Name: HSU Expense"
    echo "   • Bundle ID: expense.hsu-expense"
    echo "   • Team ID: WY3GFL6Y63"
    echo "   • Version: 1.0.0"
    echo "   • Category: Finance"
    echo ""
    echo "⚠️  Remember to prepare:"
    echo "   - App screenshots (all device sizes)"
    echo "   - App description and keywords"
    echo "   - Privacy Policy URL"
    echo "   - Support URL"
else
    echo "❌ Error: App Store IPA not found after export!"
    echo "📁 Contents of export directory:"
    ls -la "$EXPORT_PATH/"
    exit 1
fi
