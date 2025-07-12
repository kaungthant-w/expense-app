# PowerShell script to fix code signing issues for HSU Expense App
# Run this from the expense-app directory

Write-Host "🔧 HSU Expense App - Code Signing Fix" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Get current directory
$currentDir = Get-Location
Write-Host "Current directory: $currentDir" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "hsu expense.xcodeproj")) {
    Write-Host "❌ Error: hsu expense.xcodeproj not found in current directory" -ForegroundColor Red
    Write-Host "Please run this script from the expense-app directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found Xcode project" -ForegroundColor Green

# Step 1: Clean build artifacts
Write-Host "`n🧹 Step 1: Cleaning build artifacts..." -ForegroundColor Yellow

if (Test-Path "build") {
    Write-Host "Removing build/ directory..." -ForegroundColor Gray
    Remove-Item -Recurse -Force "build"
    Write-Host "✅ Removed build/ directory" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No build/ directory found" -ForegroundColor Gray
}

# Step 2: Check source folder structure
Write-Host "`n🔍 Step 2: Checking source folder structure..." -ForegroundColor Yellow

$sourceFolder = "hsu expense"
if (Test-Path $sourceFolder) {
    Write-Host "Found source folder: $sourceFolder" -ForegroundColor Green

    # Check for Swift files
    $swiftFiles = Get-ChildItem "$sourceFolder" -Filter "*.swift" -Recurse
    Write-Host "Swift files found: $($swiftFiles.Count)" -ForegroundColor Gray

    # List the Swift files
    foreach ($file in $swiftFiles) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Source folder '$sourceFolder' not found" -ForegroundColor Red
}

# Step 3: Verify export options files
Write-Host "`n📋 Step 3: Checking export options..." -ForegroundColor Yellow

$exportFiles = @("exportOptions.plist", "exportOptionsDiawi.plist", "exportOptionsAppStore.plist")
foreach ($file in $exportFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found $file" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Missing $file" -ForegroundColor Yellow
    }
}

# Step 4: Create a clean build script
Write-Host "`n📝 Step 4: Creating clean build script..." -ForegroundColor Yellow

$buildScript = @"
#!/bin/bash
# Clean build script for HSU Expense App

echo "🧹 Cleaning previous builds..."
rm -rf build/
xcodebuild clean -project "hsu expense.xcodeproj" -scheme "HSU expense"

echo "🏗️  Building for archive..."
xcodebuild archive \
  -project "hsu expense.xcodeproj" \
  -scheme "HSU expense" \
  -destination "generic/platform=iOS" \
  -archivePath "build/hsu_expense_clean.xcarchive" \
  -configuration Release \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES \
  -allowProvisioningUpdates

echo "✅ Archive completed!"
"@

$buildScript | Out-File -FilePath "clean_build.sh" -Encoding UTF8
Write-Host "✅ Created clean_build.sh" -ForegroundColor Green

# Step 5: Provide recommendations
Write-Host "`n💡 SOLUTION RECOMMENDATIONS:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

Write-Host "`n🎯 MAIN ISSUE IDENTIFIED:" -ForegroundColor Yellow
Write-Host "The 'Is a directory' error occurs because the codesign tool" -ForegroundColor White
Write-Host "is encountering an improperly structured app bundle." -ForegroundColor White

Write-Host "`n📋 TRY THESE SOLUTIONS IN ORDER:" -ForegroundColor Cyan

Write-Host "`n1. ✅ RECOMMENDED: Use Xcode IDE (Most Reliable):" -ForegroundColor Green
Write-Host "   • Open 'hsu expense.xcodeproj' in Xcode" -ForegroundColor Gray
Write-Host "   • Select 'HSU expense' scheme" -ForegroundColor Gray
Write-Host "   • Select 'Any iOS Device' or your connected device" -ForegroundColor Gray
Write-Host "   • Go to Product → Clean Build Folder (Cmd+Shift+K)" -ForegroundColor Gray
Write-Host "   • Go to Product → Archive (Cmd+Shift+R)" -ForegroundColor Gray

Write-Host "`n2. 🔧 Alternative: Clean Command Line Build:" -ForegroundColor Yellow
Write-Host "   bash clean_build.sh" -ForegroundColor Gray

Write-Host "`n3. 🛠️  If still failing, check these settings:" -ForegroundColor Yellow
Write-Host "   • Signing & Capabilities in Xcode project settings" -ForegroundColor Gray
Write-Host "   • Ensure 'Automatically manage signing' is enabled" -ForegroundColor Gray
Write-Host "   • Verify Team ID: WY3GFL6Y63" -ForegroundColor Gray
Write-Host "   • Bundle ID: expense.hsu-expense" -ForegroundColor Gray

Write-Host "`n4. 🔍 Advanced Debugging:" -ForegroundColor Yellow
Write-Host "   • Check that no files in source folder have invalid names" -ForegroundColor Gray
Write-Host "   • Ensure no symbolic links or hidden files in project" -ForegroundColor Gray
Write-Host "   • Verify provisioning profile is not expired" -ForegroundColor Gray

Write-Host "`n⚡ QUICK FIX SUMMARY:" -ForegroundColor Cyan
Write-Host "The most reliable solution is to use Xcode IDE instead of" -ForegroundColor White
Write-Host "command line tools. Xcode handles app bundle creation and" -ForegroundColor White
Write-Host "code signing more reliably for complex projects." -ForegroundColor White

Write-Host "`n✅ Code signing analysis completed!" -ForegroundColor Green
