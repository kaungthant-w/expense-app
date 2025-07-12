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

# Step 2: Clean Xcode derived data (if accessible)
Write-Host "`n🧹 Step 2: Cleaning Xcode derived data..." -ForegroundColor Yellow
$derivedDataPath = "$env:HOME/Library/Developer/Xcode/DerivedData"

if (Test-Path $derivedDataPath) {
    Write-Host "Cleaning Xcode derived data..." -ForegroundColor Gray
    try {
        # Clean specific project derived data
        Get-ChildItem "$derivedDataPath" -Directory | Where-Object { $_.Name -like "*hsu*expense*" -or $_.Name -like "*HSU*expense*" } | Remove-Item -Recurse -Force
        Write-Host "✅ Cleaned Xcode derived data" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not clean derived data (this is okay): $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "ℹ️  Derived data path not accessible from PowerShell" -ForegroundColor Gray
}

# Step 3: Check source folder structure
Write-Host "`n🔍 Step 3: Checking source folder structure..." -ForegroundColor Yellow

$sourceFolder = "hsu expense"
if (Test-Path $sourceFolder) {
    Write-Host "Found source folder: $sourceFolder" -ForegroundColor Green

    # Check for problematic files
    $swiftFiles = Get-ChildItem "$sourceFolder" -Filter "*.swift" -Recurse
    Write-Host "Swift files found: $($swiftFiles.Count)" -ForegroundColor Gray

    # Check for hidden files or invalid characters
    $allFiles = Get-ChildItem "$sourceFolder" -Recurse -Force
    $problematicFiles = $allFiles | Where-Object { $_.Name -match '[<>:"/\\|?*]' -or $_.Name.StartsWith('.') }

    if ($problematicFiles.Count -gt 0) {
        Write-Host "⚠️  Found potentially problematic files:" -ForegroundColor Yellow
        $problematicFiles | ForEach-Object { Write-Host "  - $($_.FullName)" -ForegroundColor Gray }
    } else {
        Write-Host "✅ Source folder structure looks good" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Source folder '$sourceFolder' not found" -ForegroundColor Red
}

# Step 4: Verify export options files
Write-Host "`n📋 Step 4: Checking export options..." -ForegroundColor Yellow

$exportFiles = @("exportOptions.plist", "exportOptionsDiawi.plist", "exportOptionsAppStore.plist")
foreach ($file in $exportFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found $file" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Missing $file" -ForegroundColor Yellow
    }
}

# Step 5: Create a clean build script
Write-Host "`n📝 Step 5: Creating clean build script..." -ForegroundColor Yellow

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

# Step 6: Provide recommendations
Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Try building with Xcode IDE first:" -ForegroundColor White
Write-Host "   - Open 'hsu expense.xcodeproj' in Xcode" -ForegroundColor Gray
Write-Host "   - Select 'HSU expense' scheme" -ForegroundColor Gray
Write-Host "   - Select 'Any iOS Device' or your connected device" -ForegroundColor Gray
Write-Host "   - Go to Product → Clean Build Folder" -ForegroundColor Gray
Write-Host "   - Go to Product → Archive" -ForegroundColor Gray

Write-Host "`n2. If Xcode fails, try the clean build script:" -ForegroundColor White
Write-Host "   bash clean_build.sh" -ForegroundColor Gray

Write-Host "`n3. If still having issues, check:" -ForegroundColor White
Write-Host "   - Code signing certificate is valid" -ForegroundColor Gray
Write-Host "   - Provisioning profile is up to date" -ForegroundColor Gray
Write-Host "   - Bundle identifier matches provisioning profile" -ForegroundColor Gray
Write-Host "   - No duplicate files in source folder" -ForegroundColor Gray

Write-Host "`n🎯 The main issue appears to be the app bundle structure during the build process." -ForegroundColor Cyan
Write-Host "Using Xcode IDE often resolves this type of code signing issue." -ForegroundColor Cyan

Write-Host "`n✅ Code signing fix preparation completed!" -ForegroundColor Green
