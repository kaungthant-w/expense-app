#!/bin/zsh
# build_ipa.sh - Archive and export .ipa for hsu expense app

set -e

WORKSPACE="hsu expense.xcodeproj/project.xcworkspace"
SCHEME="hsu expense"
ARCHIVE_PATH="build/hsu_expense.xcarchive"
EXPORT_PATH="build/ipa"
EXPORT_OPTIONS="exportOptions.plist"

# Clean previous build
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

# Archive the app
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release -archivePath "$ARCHIVE_PATH" archive

# Export the .ipa
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist "$EXPORT_OPTIONS"

echo "IPA exported to $EXPORT_PATH"
