# Test Currency Conversion Script
Write-Host "🧪 Testing Currency Conversion Logic" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Test data: $50 USD, 2000 MMK, EUR30 EUR
Write-Host ""
Write-Host "📊 Test Expenses:" -ForegroundColor Cyan
Write-Host "- $50.00 USD"
Write-Host "- 2,000 MMK"
Write-Host "- EUR30.00 EUR"
Write-Host ""

# Exchange rates (fallback rates from CurrencyManager)
$USD_RATE = 1.0
$MMK_RATE = 2100.0
$EUR_RATE = 0.85

Write-Host "💱 Exchange Rates (USD base):" -ForegroundColor Yellow
Write-Host "- USD: $USD_RATE"
Write-Host "- MMK: $MMK_RATE"
Write-Host "- EUR: $EUR_RATE"
Write-Host ""

# Test conversion to USD
Write-Host "🔄 Converting to USD:" -ForegroundColor Magenta
# $50 USD = $50
$USD_TO_USD = 50 * $USD_RATE
Write-Host "- $50 USD → $" -NoNewline; Write-Host ("{0:F2}" -f $USD_TO_USD)

# 2000 MMK to USD = 2000 / 2100 = $0.95
$MMK_TO_USD = 2000 / $MMK_RATE
Write-Host "- 2,000 MMK → $" -NoNewline; Write-Host ("{0:F2}" -f $MMK_TO_USD)

# EUR30 EUR to USD = 30 / 0.85 = $35.29
$EUR_TO_USD = 30 / $EUR_RATE
Write-Host "- EUR30 EUR → $" -NoNewline; Write-Host ("{0:F2}" -f $EUR_TO_USD)

# Total in USD
$TOTAL_USD = $USD_TO_USD + $MMK_TO_USD + $EUR_TO_USD
Write-Host "- TOTAL: $" -NoNewline -ForegroundColor Green; Write-Host ("{0:F2}" -f $TOTAL_USD) -ForegroundColor Green
Write-Host ""

# Test conversion to MMK
Write-Host "🔄 Converting to MMK:" -ForegroundColor Magenta
# $50 USD to MMK = 50 * 2100 = 105,000 MMK
$USD_TO_MMK = 50 * $MMK_RATE
Write-Host "- $50 USD → {0:N0} MMK" -f $USD_TO_MMK

# 2000 MMK = 2000 MMK
$MMK_TO_MMK = 2000
Write-Host "- 2,000 MMK → {0:N0} MMK" -f $MMK_TO_MMK

# EUR30 EUR to MMK = (30 / 0.85) * 2100 = 74,118 MMK
$EUR_TO_MMK = (30 / $EUR_RATE) * $MMK_RATE
Write-Host "- EUR30 EUR → {0:N0} MMK" -f $EUR_TO_MMK

# Total in MMK
$TOTAL_MMK = $USD_TO_MMK + $MMK_TO_MMK + $EUR_TO_MMK
Write-Host "- TOTAL: " -NoNewline -ForegroundColor Green; Write-Host ("{0:N0} MMK" -f $TOTAL_MMK) -ForegroundColor Green
Write-Host ""

# Test conversion to EUR
Write-Host "🔄 Converting to EUR:" -ForegroundColor Magenta
# $50 USD to EUR = 50 * 0.85 = EUR42.50
$USD_TO_EUR = 50 * $EUR_RATE
Write-Host "- $50 USD → EUR{0:F2}" -f $USD_TO_EUR

# 2000 MMK to EUR = (2000 / 2100) * 0.85 = EUR0.81
$MMK_TO_EUR = (2000 / $MMK_RATE) * $EUR_RATE
Write-Host "- 2,000 MMK → EUR{0:F2}" -f $MMK_TO_EUR

# EUR30 EUR = EUR30
$EUR_TO_EUR = 30
Write-Host "- EUR30 EUR → EUR{0:F2}" -f $EUR_TO_EUR

# Total in EUR
$TOTAL_EUR = $USD_TO_EUR + $MMK_TO_EUR + $EUR_TO_EUR
Write-Host "- TOTAL: " -NoNewline -ForegroundColor Green; Write-Host ("EUR{0:F2}" -f $TOTAL_EUR) -ForegroundColor Green
Write-Host ""

Write-Host "✅ Expected Results:" -ForegroundColor Green
Write-Host "- Switch to USD → $" -NoNewline; Write-Host ("{0:F2}" -f $TOTAL_USD) -NoNewline; Write-Host " total"
Write-Host "- Switch to MMK → " -NoNewline; Write-Host ("{0:N0}" -f $TOTAL_MMK) -NoNewline; Write-Host " MMK total"
Write-Host "- Switch to EUR → EUR" -NoNewline; Write-Host ("{0:F2}" -f $TOTAL_EUR) -NoNewline; Write-Host " total"
