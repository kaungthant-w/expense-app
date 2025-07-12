#!/bin/zsh
# build_ipa.sh - Archive and export .ipa for hsu expense app

set -e

PROJECT="hsu expense.xcodeproj"
SCHEME="HSU expense"
ARCHIVE_PATH="build/hsu_expense.xcarchive"
EXPORT_PATH="build/ipa"
EXPORT_OPTIONS="exportOptions.plist"

echo "📱 Building HSU Expense App"
echo "Project: $PROJECT"
echo "Scheme: $SCHEME"
echo ""

# List available schemes for debugging
echo "Available schemes:"
xcodebuild -project "$PROJECT" -list

echo ""
echo "🧹 Cleaning previous build..."
# Clean previous build
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

echo "🏗️ Archiving the app..."
# Archive the app
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release -archivePath "$ARCHIVE_PATH" archive

echo "📦 Exporting IPA..."
# Export the .ipa
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist "$EXPORT_OPTIONS"

echo "✅ IPA exported to $EXPORT_PATH"
