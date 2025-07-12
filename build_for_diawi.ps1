# build_for_diawi.ps1 - Build and prepare IPA for Diawi distribution

$PROJECT = "hsu expense.xcodeproj"
$SCHEME = "HSU expense"
$ARCHIVE_PATH = "build/hsu_expense.xcarchive"
$EXPORT_PATH = "build/ipa"
$EXPORT_OPTIONS = "exportOptionsDiawi.plist"

Write-Host "🚀 Building HSU Expense for Diawi Distribution" -ForegroundColor Green
Write-Host "=" * 50
Write-Host "Project: $PROJECT"
Write-Host "Scheme: $SCHEME"
Write-Host "Export Options: $EXPORT_OPTIONS"
Write-Host ""

# Check if we have the required files
if (-not (Test-Path "$PROJECT/project.pbxproj")) {
    Write-Host "❌ Error: Xcode project not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $EXPORT_OPTIONS)) {
    Write-Host "❌ Error: Export options file not found!" -ForegroundColor Red
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
Write-Host "🏗️  Archiving for device..." -ForegroundColor Blue
# Archive the app for device
& xcodebuild -project $PROJECT -scheme $SCHEME -configuration "Release" -archivePath $ARCHIVE_PATH -destination "generic/platform=iOS" archive

Write-Host ""
Write-Host "📦 Exporting IPA for Diawi..." -ForegroundColor Blue
# Export the .ipa
& xcodebuild -exportArchive -archivePath $ARCHIVE_PATH -exportPath $EXPORT_PATH -exportOptionsPlist $EXPORT_OPTIONS

Write-Host ""
Write-Host "📝 Renaming and organizing files..." -ForegroundColor Yellow

# Find and rename the IPA file
$ipaFiles = @(
    "$EXPORT_PATH/hsu expense.ipa",
    "$EXPORT_PATH/HSU expense.ipa"
)

$finalIPA = "$EXPORT_PATH/HSU Expense.ipa"
$found = $false

foreach ($ipa in $ipaFiles) {
    if (Test-Path $ipa) {
        Move-Item $ipa $finalIPA -Force
        Write-Host "✅ IPA renamed to 'HSU Expense.ipa'" -ForegroundColor Green
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Host "⚠️  Looking for IPA files in export directory..." -ForegroundColor Yellow
    $allIpas = Get-ChildItem -Path $EXPORT_PATH -Filter "*.ipa"
    if ($allIpas.Count -gt 0) {
        Move-Item $allIpas[0].FullName $finalIPA -Force
        $found = $true
    }
}

# Verify the final IPA exists
if (Test-Path $finalIPA) {
    $fileSize = (Get-Item $finalIPA).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    
    Write-Host ""
    Write-Host "✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "=" * 30
    Write-Host "📱 IPA File: $finalIPA"
    Write-Host "📊 File Size: $fileSizeMB MB"
    Write-Host ""
    Write-Host "🌐 Ready for Diawi Upload!" -ForegroundColor Cyan
    Write-Host "   1. Go to https://www.diawi.com"
    Write-Host "   2. Upload: $finalIPA"
    Write-Host "   3. Set password (optional but recommended)"
    Write-Host "   4. Add comment: HSU Expense v1.0"
    Write-Host "   5. Share QR code with testers"
    Write-Host ""
    Write-Host "📋 Troubleshooting Tips:" -ForegroundColor Yellow
    Write-Host "   - Ensure test devices are registered in Apple Developer"
    Write-Host "   - Check provisioning profile includes target devices"
    Write-Host "   - Verify bundle ID matches developer account"
    Write-Host "   - Test installation on registered device first"
} else {
    Write-Host "❌ Error: IPA file not found after export!" -ForegroundColor Red
    Write-Host "📁 Contents of export directory:"
    Get-ChildItem $EXPORT_PATH
    exit 1
}
