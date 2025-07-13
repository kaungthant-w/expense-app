Write-Host "Currency Conversion Test" -ForegroundColor Green

# Exchange rates
$USD_RATE = 1.0
$MMK_RATE = 2100.0
$EUR_RATE = 0.85

Write-Host "Test Expenses: 50 USD, 2000 MMK, 30 EUR"
Write-Host ""

# Convert to USD
$USD_TOTAL = (50 * $USD_RATE) + (2000 / $MMK_RATE) + (30 / $EUR_RATE)
Write-Host "USD Total: " -NoNewline
Write-Host ("{0:F2}" -f $USD_TOTAL) -ForegroundColor Yellow

# Convert to MMK
$MMK_TOTAL = (50 * $MMK_RATE) + (2000 * 1) + ((30 / $EUR_RATE) * $MMK_RATE)
Write-Host "MMK Total: " -NoNewline
Write-Host ("{0:N0}" -f $MMK_TOTAL) -ForegroundColor Yellow

# Convert to EUR
$EUR_TOTAL = (50 * $EUR_RATE) + ((2000 / $MMK_RATE) * $EUR_RATE) + (30 * 1)
Write-Host "EUR Total: " -NoNewline
Write-Host ("{0:F2}" -f $EUR_TOTAL) -ForegroundColor Yellow

Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Green
Write-Host "- USD: $" -NoNewline; Write-Host ("{0:F2}" -f $USD_TOTAL)
Write-Host "- MMK: " -NoNewline; Write-Host ("{0:N0}" -f $MMK_TOTAL) -NoNewline; Write-Host " MMK"
Write-Host "- EUR: " -NoNewline; Write-Host ("{0:F2}" -f $EUR_TOTAL) -NoNewline; Write-Host " EUR"
