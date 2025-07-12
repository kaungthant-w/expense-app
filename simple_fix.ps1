Write-Host "HSU Expense App - Code Signing Fix" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "hsu expense.xcodeproj")) {
    Write-Host "Error: hsu expense.xcodeproj not found" -ForegroundColor Red
    Write-Host "Please run this script from the expense-app directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "Found Xcode project" -ForegroundColor Green

# Clean build artifacts
Write-Host "`nStep 1: Cleaning build artifacts..." -ForegroundColor Yellow

if (Test-Path "build") {
    Write-Host "Removing build directory..." -ForegroundColor Gray
    Remove-Item -Recurse -Force "build"
    Write-Host "Removed build directory" -ForegroundColor Green
} else {
    Write-Host "No build directory found" -ForegroundColor Gray
}

# Check source folder
Write-Host "`nStep 2: Checking source folder..." -ForegroundColor Yellow

$sourceFolder = "hsu expense"
if (Test-Path $sourceFolder) {
    Write-Host "Found source folder: $sourceFolder" -ForegroundColor Green

    $swiftFiles = Get-ChildItem "$sourceFolder" -Filter "*.swift" -Recurse
    Write-Host "Swift files found: $($swiftFiles.Count)" -ForegroundColor Gray
} else {
    Write-Host "Source folder not found" -ForegroundColor Red
}

# Check export options
Write-Host "`nStep 3: Checking export options..." -ForegroundColor Yellow

$exportFiles = @("exportOptions.plist", "exportOptionsDiawi.plist", "exportOptionsAppStore.plist")
foreach ($file in $exportFiles) {
    if (Test-Path $file) {
        Write-Host "Found $file" -ForegroundColor Green
    } else {
        Write-Host "Missing $file" -ForegroundColor Yellow
    }
}

Write-Host "`nRECOMMENDED SOLUTIONS:" -ForegroundColor Cyan
Write-Host "1. Use Xcode IDE for most reliable results" -ForegroundColor White
Write-Host "   - Open hsu expense.xcodeproj in Xcode" -ForegroundColor Gray
Write-Host "   - Product -> Clean Build Folder" -ForegroundColor Gray
Write-Host "   - Product -> Archive" -ForegroundColor Gray

Write-Host "`n2. The main issue is app bundle structure during build" -ForegroundColor White
Write-Host "   The codesign tool is seeing a directory instead of proper app bundle" -ForegroundColor Gray

Write-Host "`n3. Verify in Xcode project settings:" -ForegroundColor White
Write-Host "   - Signing & Capabilities tab" -ForegroundColor Gray
Write-Host "   - Automatically manage signing enabled" -ForegroundColor Gray
Write-Host "   - Team: WY3GFL6Y63" -ForegroundColor Gray
Write-Host "   - Bundle ID: expense.hsu-expense" -ForegroundColor Gray

Write-Host "`nCode signing analysis completed!" -ForegroundColor Green
