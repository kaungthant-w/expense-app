#!/bin/bash

# Test Currency Conversion Script
echo "🧪 Testing Currency Conversion Logic"
echo "======================================"

# Test data: $50 USD, 2000 MMK, €30 EUR
echo ""
echo "📊 Test Expenses:"
echo "- $50.00 USD"
echo "- 2,000 MMK"
echo "- €30.00 EUR"
echo ""

# Exchange rates (fallback rates from CurrencyManager)
USD_RATE=1.0
MMK_RATE=2100.0
EUR_RATE=0.85

echo "💱 Exchange Rates (USD base):"
echo "- USD: $USD_RATE"
echo "- MMK: $MMK_RATE"
echo "- EUR: $EUR_RATE"
echo ""

# Test conversion to USD
echo "🔄 Converting to USD:"
# $50 USD = $50
USD_TO_USD=$(echo "50 * $USD_RATE" | bc -l)
echo "- $50 USD → \$$USD_TO_USD"

# 2000 MMK to USD = 2000 / 2100 = $0.95
MMK_TO_USD=$(echo "2000 / $MMK_RATE" | bc -l)
echo "- 2,000 MMK → \$$(printf "%.2f" $MMK_TO_USD)"

# €30 EUR to USD = 30 / 0.85 = $35.29
EUR_TO_USD=$(echo "30 / $EUR_RATE" | bc -l)
echo "- €30 EUR → \$$(printf "%.2f" $EUR_TO_USD)"

# Total in USD
TOTAL_USD=$(echo "$USD_TO_USD + $MMK_TO_USD + $EUR_TO_USD" | bc -l)
echo "- TOTAL: \$$(printf "%.2f" $TOTAL_USD)"
echo ""

# Test conversion to MMK
echo "🔄 Converting to MMK:"
# $50 USD to MMK = 50 * 2100 = 105,000 MMK
USD_TO_MMK=$(echo "50 * $MMK_RATE" | bc -l)
echo "- $50 USD → $(printf "%.0f" $USD_TO_MMK) MMK"

# 2000 MMK = 2000 MMK
MMK_TO_MMK=2000
echo "- 2,000 MMK → $MMK_TO_MMK MMK"

# €30 EUR to MMK = (30 / 0.85) * 2100 = 74,118 MMK
EUR_TO_MMK=$(echo "(30 / $EUR_RATE) * $MMK_RATE" | bc -l)
echo "- €30 EUR → $(printf "%.0f" $EUR_TO_MMK) MMK"

# Total in MMK
TOTAL_MMK=$(echo "$USD_TO_MMK + $MMK_TO_MMK + $EUR_TO_MMK" | bc -l)
echo "- TOTAL: $(printf "%.0f" $TOTAL_MMK) MMK"
echo ""

# Test conversion to EUR
echo "🔄 Converting to EUR:"
# $50 USD to EUR = 50 * 0.85 = €42.50
USD_TO_EUR=$(echo "50 * $EUR_RATE" | bc -l)
echo "- $50 USD → €$(printf "%.2f" $USD_TO_EUR)"

# 2000 MMK to EUR = (2000 / 2100) * 0.85 = €0.81
MMK_TO_EUR=$(echo "(2000 / $MMK_RATE) * $EUR_RATE" | bc -l)
echo "- 2,000 MMK → €$(printf "%.2f" $MMK_TO_EUR)"

# €30 EUR = €30
EUR_TO_EUR=30
echo "- €30 EUR → €$EUR_TO_EUR"

# Total in EUR
TOTAL_EUR=$(echo "$USD_TO_EUR + $MMK_TO_EUR + $EUR_TO_EUR" | bc -l)
echo "- TOTAL: €$(printf "%.2f" $TOTAL_EUR)"
echo ""

echo "✅ Expected Results:"
echo "- Switch to USD → \$$(printf "%.2f" $TOTAL_USD) total"
echo "- Switch to MMK → $(printf "%.0f" $TOTAL_MMK) MMK total"
echo "- Switch to EUR → €$(printf "%.2f" $TOTAL_EUR) total"
