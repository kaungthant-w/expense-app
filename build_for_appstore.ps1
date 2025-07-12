# build_for_appstore.ps1 - Build and prepare IPA for App Store distribution

$PROJECT = "hsu expense.xcodeproj"
$SCHEME = "HSU expense"
$ARCHIVE_PATH = "build/hsu_expense_appstore.xcarchive"
$EXPORT_PATH = "build/appstore"
$EXPORT_OPTIONS = "exportOptionsAppStore.plist"

Write-Host "🏪 Building HSU Expense for App Store" -ForegroundColor Green
Write-Host "=" * 40
Write-Host "Project: $PROJECT"
Write-Host "Scheme: $SCHEME"
Write-Host "Export Options: $EXPORT_OPTIONS"
Write-Host "Bundle ID: expense.hsu-expense"
Write-Host ""

# Check if we have the required files
if (-not (Test-Path "$PROJECT/project.pbxproj")) {
    Write-Host "❌ Error: Xcode project not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $EXPORT_OPTIONS)) {
    Write-Host "❌ Error: App Store export options file not found!" -ForegroundColor Red
    exit 1
}

# List available schemes for debugging
Write-Host "📋 Available schemes:" -ForegroundColor Yellow
& xcodebuild -project $PROJECT -list

Write-Host ""
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path $ARCHIVE_PATH) { Remove-Item -Recurse -Force $ARCHIVE_PATH }
if (Test-Path $EXPORT_PATH) { Remove-Item -Recurse -Force $EXPORT_PATH }
if (-not (Test-Path "build")) { New-Item -ItemType Directory -Path "build" }

Write-Host ""
Write-Host "🏗️  Archiving for App Store..." -ForegroundColor Blue
# Archive the app for App Store
& xcodebuild -project $PROJECT -scheme $SCHEME -configuration "Release" -archivePath $ARCHIVE_PATH -destination "generic/platform=iOS" archive

Write-Host ""
Write-Host "📦 Exporting for App Store..." -ForegroundColor Blue
# Export for App Store
& xcodebuild -exportArchive -archivePath $ARCHIVE_PATH -exportPath $EXPORT_PATH -exportOptionsPlist $EXPORT_OPTIONS

Write-Host ""
Write-Host "📝 Organizing App Store files..." -ForegroundColor Yellow

# The App Store export creates a different file structure
$appStoreIPA = "$EXPORT_PATH/HSU expense.ipa"
$found = $false

$ipaFiles = @(
    "$EXPORT_PATH/HSU expense.ipa",
    "$EXPORT_PATH/hsu expense.ipa"
)

foreach ($ipa in $ipaFiles) {
    if (Test-Path $ipa) {
        if ($ipa -ne $appStoreIPA) {
            Move-Item $ipa $appStoreIPA -Force
        }
        Write-Host "✅ App Store IPA created: $appStoreIPA" -ForegroundColor Green
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Host "⚠️  Looking for IPA files in export directory..." -ForegroundColor Yellow
    $allIpas = Get-ChildItem -Path $EXPORT_PATH -Filter "*.ipa"
    if ($allIpas.Count -gt 0) {
        Move-Item $allIpas[0].FullName $appStoreIPA -Force
        $found = $true
    }
}

# Verify the final IPA exists
if (Test-Path $appStoreIPA) {
    $fileSize = (Get-Item $appStoreIPA).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    
    Write-Host ""
    Write-Host "✅ APP STORE BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "=" * 35
    Write-Host "📱 IPA File: $appStoreIPA"
    Write-Host "📊 File Size: $fileSizeMB MB"
    Write-Host ""
    Write-Host "🏪 Ready for App Store Upload!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Create App Store Connect record"
    Write-Host "   2. Upload via Xcode or Application Loader"
    Write-Host "   3. Fill in App Store metadata"
    Write-Host "   4. Submit for App Store Review"
    Write-Host ""
    Write-Host "📝 App Information Summary:" -ForegroundColor Cyan
    Write-Host "   • App Name: HSU Expense"
    Write-Host "   • Bundle ID: expense.hsu-expense"
    Write-Host "   • Team ID: WY3GFL6Y63"
    Write-Host "   • Version: 1.0.0"
    Write-Host "   • Category: Finance"
    Write-Host ""
    Write-Host "⚠️  Remember to prepare:" -ForegroundColor Yellow
    Write-Host "   - App screenshots (all device sizes)"
    Write-Host "   - App description and keywords"
    Write-Host "   - Privacy Policy URL"
    Write-Host "   - Support URL"
} else {
    Write-Host "❌ Error: App Store IPA not found after export!" -ForegroundColor Red
    Write-Host "📁 Contents of export directory:"
    Get-ChildItem $EXPORT_PATH
    exit 1
}
