# Enhanced iOS Features - Add Files to Xcode Script
# This PowerShell script helps organize the enhanced files for Xcode integration

Write-Host "Enhanced iOS Expense App - File Integration Helper" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

# List of new enhanced files
$enhancedFiles = @(
    "EnhancedExportDataView.swift",
    "EnhancedImportDataView.swift",
    "EnhancedLanguageSettingsView.swift",
    "EnhancedThemeSettingsView.swift",
    "EnhancedSettingsCardView.swift"
)

Write-Host "`nChecking for enhanced files..." -ForegroundColor Yellow

$projectPath = "hsu expense"
$foundFiles = @()
$missingFiles = @()

foreach ($file in $enhancedFiles) {
    $filePath = Join-Path $projectPath $file
    if (Test-Path $filePath) {
        $foundFiles += $file
        Write-Host "Found: $file" -ForegroundColor Green
    } else {
        $missingFiles += $file
        Write-Host "Missing: $file" -ForegroundColor Red
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Found: $($foundFiles.Count) files" -ForegroundColor Green
Write-Host "Missing: $($missingFiles.Count) files" -ForegroundColor Red

if ($foundFiles.Count -gt 0) {
    Write-Host "`nNext Steps for Xcode Integration:" -ForegroundColor Yellow
    Write-Host "1. Open hsu expense.xcodeproj in Xcode"
    Write-Host "2. Right-click on hsu expense folder in Project Navigator"
    Write-Host "3. Select Add Files to hsu expense"
    Write-Host "4. Add these files:" -ForegroundColor Cyan

    foreach ($file in $foundFiles) {
        Write-Host "   $file" -ForegroundColor White
    }

    Write-Host "5. Make sure Add to target: hsu expense is checked"
    Write-Host "6. Click Add"
    Write-Host "7. Build project to verify integration"
}

Write-Host "`nFeatures Added:" -ForegroundColor Green
Write-Host "Android-style card layouts with shadows"
Write-Host "Multi-language support with flags (10 languages)"
Write-Host "Advanced theme switching (Light/Dark/System)"
Write-Host "Export data in JSON/CSV/TXT formats"
Write-Host "Import data with file picker and validation"
Write-Host "Enhanced settings with modern UI components"

Write-Host "`nReady to build your enhanced expense app!" -ForegroundColor Magenta
