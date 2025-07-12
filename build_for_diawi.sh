#!/bin/bash
# build_for_diawi.sh - Build and prepare IPA for Diawi distribution

set -e

PROJECT="hsu expense.xcodeproj"
SCHEME="HSU expense"
ARCHIVE_PATH="build/hsu_expense.xcarchive"
EXPORT_PATH="build/ipa"
EXPORT_OPTIONS="exportOptionsDiawi.plist"

echo "🚀 Building HSU Expense for Diawi Distribution"
echo "=============================================="
echo "Project: $PROJECT"
echo "Scheme: $SCHEME"
echo "Export Options: $EXPORT_OPTIONS"
echo ""

# Check if we have the required files
if [ ! -f "$PROJECT/project.pbxproj" ]; then
    echo "❌ Error: Xcode project not found!"
    exit 1
fi

if [ ! -f "$EXPORT_OPTIONS" ]; then
    echo "❌ Error: Export options file not found!"
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
echo "🏗️  Archiving for device..."
# Archive the app for device
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    archive

echo ""
echo "📦 Exporting IPA for Diawi..."
# Export the .ipa
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

echo ""
echo "📝 Renaming and organizing files..."
# Find and rename the IPA file
if [ -f "$EXPORT_PATH/hsu expense.ipa" ]; then
    mv "$EXPORT_PATH/hsu expense.ipa" "$EXPORT_PATH/HSU Expense.ipa"
    echo "✅ IPA renamed to 'HSU Expense.ipa'"
elif [ -f "$EXPORT_PATH/HSU expense.ipa" ]; then
    mv "$EXPORT_PATH/HSU expense.ipa" "$EXPORT_PATH/HSU Expense.ipa"
    echo "✅ IPA renamed to 'HSU Expense.ipa'"
else
    echo "⚠️  Looking for IPA files in export directory..."
    find "$EXPORT_PATH" -name "*.ipa" -exec mv {} "$EXPORT_PATH/HSU Expense.ipa" \;
fi

# Verify the final IPA exists
if [ -f "$EXPORT_PATH/HSU Expense.ipa" ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo "========================"
    echo "📱 IPA File: $EXPORT_PATH/HSU Expense.ipa"
    echo "📊 File Size: $(du -h "$EXPORT_PATH/HSU Expense.ipa" | cut -f1)"
    echo ""
    echo "🌐 Ready for Diawi Upload!"
    echo "   1. Go to https://www.diawi.com"
    echo "   2. Upload: $EXPORT_PATH/HSU Expense.ipa"
    echo "   3. Set password (optional but recommended)"
    echo "   4. Add comment: HSU Expense v1.0"
    echo "   5. Share QR code with testers"
    echo ""
    echo "📋 Troubleshooting Tips:"
    echo "   - Ensure test devices are registered in Apple Developer"
    echo "   - Check provisioning profile includes target devices"
    echo "   - Verify bundle ID matches developer account"
    echo "   - Test installation on registered device first"
else
    echo "❌ Error: IPA file not found after export!"
    echo "📁 Contents of export directory:"
    ls -la "$EXPORT_PATH/"
    exit 1
fi
