import SwiftUI

struct CurrencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var showingUpdateSuccess = false
    @State private var showingUpdateError = false
    @State private var updateMessage = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Info Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Currency")
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)

                            HStack(spacing: 8) {
                                Text(currencyManager.currentCurrency.flag)
                                    .font(.title2)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(currencyManager.currentCurrency.name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.expensePrimaryText)

                                    Text("\(currencyManager.currentCurrency.symbol) \(currencyManager.currentCurrency.code)")
                                        .font(.caption)
                                        .foregroundColor(.expenseSecondaryText)
                                }
                            }
                        }

                        Spacer()
                    }

                    Divider()

                    // Last Update Info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exchange Rates")
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)

                            Text("Last updated: \(currencyManager.lastUpdateString)")
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)
                        }

                        Spacer()

                        // Update Button
                        Button(action: {
                            updateExchangeRates()
                        }) {
                            HStack(spacing: 6) {
                                if currencyManager.isUpdatingRates {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                }

                                Text(currencyManager.isUpdatingRates ? "Updating..." : "Update")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.expenseAccent)
                            )
                        }
                        .disabled(currencyManager.isUpdatingRates)
                    }
                }
                .padding(20)
                .background(Color.expenseCardBackground)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Currency Grid
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section Header
                        HStack {
                            Text("Available Currencies")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.expenseSecondaryText)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // 3-Column Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 12) {
                            ForEach(CurrencyManager.Currency.allCurrencies, id: \.code) { currency in
                                CurrencyCardView(
                                    currency: currency,
                                    isSelected: currency.code == currencyManager.currentCurrency.code,
                                    exchangeRate: currencyManager.exchangeRates[currency.code] ?? 1.0
                                ) {
                                    selectCurrency(currency)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                }
            }
            .background(Color.expenseBackground)
            .navigationTitle("Currency Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showingUpdateSuccess) {
                Button("OK") { }
            } message: {
                Text(updateMessage)
            }
            .alert("Update Failed", isPresented: $showingUpdateError) {
                Button("OK") { }
                Button("Retry") {
                    updateExchangeRates()
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func selectCurrency(_ currency: CurrencyManager.Currency) {
        currencyManager.setCurrency(currency)

        // Show feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        updateMessage = "Currency changed to \(currency.name)"
        showingUpdateSuccess = true
    }

    private func updateExchangeRates() {
        currencyManager.updateExchangeRates()

        // Listen for successful completion
        NotificationCenter.default.addObserver(
            forName: .exchangeRatesUpdated,
            object: nil,
            queue: .main
        ) { _ in
            updateMessage = "Exchange rates updated successfully from Myanmar Currency API! 🇲🇲"
            showingUpdateSuccess = true
        }

        // Listen for API errors
        NotificationCenter.default.addObserver(
            forName: .exchangeRatesFailed,
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo,
               let error = userInfo["error"] as? String {
                errorMessage = "Failed to update exchange rates: \(error)\n\nUsing fallback rates instead."
            } else {
                errorMessage = "Failed to update exchange rates. Using fallback rates instead."
            }
            showingUpdateError = true
        }
    }
}

// MARK: - Currency Card View for 3-Column Grid
struct CurrencyCardView: View {
    let currency: CurrencyManager.Currency
    let isSelected: Bool
    let exchangeRate: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Flag and Selection Indicator
                ZStack {
                    Text(currency.flag)
                        .font(.system(size: 28))

                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.expenseGreen)
                                    .background(
                                        Circle()
                                            .fill(Color.expenseCardBackground)
                                            .frame(width: 16, height: 16)
                                    )
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 40)

                // Currency Info
                VStack(spacing: 2) {
                    Text(currency.code)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.expensePrimaryText)

                    Text(currency.symbol)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                // Exchange Rate
                VStack(spacing: 2) {
                    if currency.code != "USD" {
                        Text("1 USD")
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)

                        Text("\(String(format: "%.2f", exchangeRate)) \(currency.code)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.expenseAccent)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        // Special indicator for MMK (main API focus)
                        if currency.code == "MMK" {
                            Image(systemName: "wifi")
                                .font(.caption2)
                                .foregroundColor(.expenseGreen)
                        }
                    } else {
                        Text("Base")
                            .font(.caption2)
                            .foregroundColor(.expenseAccent)
                            .fontWeight(.medium)

                        Text("Currency")
                            .font(.caption2)
                            .foregroundColor(.expenseAccent)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.expenseGreen.opacity(0.1) : Color.expenseCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.expenseGreen : Color.expenseCardBorder,
                                lineWidth: isSelected ? 2 : 0.5
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CurrencyRowView: View {
    let currency: CurrencyManager.Currency
    let isSelected: Bool
    let exchangeRate: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flag and Currency Info
                HStack(spacing: 12) {
                    Text(currency.flag)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currency.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.expensePrimaryText)

                        Text("\(currency.symbol) \(currency.code)")
                            .font(.caption)
                            .foregroundColor(.expenseSecondaryText)
                    }
                }

                Spacer()

                // Exchange Rate
                VStack(alignment: .trailing, spacing: 2) {
                    if currency.code != "USD" {
                        HStack(spacing: 4) {
                            Text("1 USD = \(String(format: "%.2f", exchangeRate)) \(currency.code)")
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)

                            // Special indicator for MMK (main API focus)
                            if currency.code == "MMK" {
                                Image(systemName: "wifi")
                                    .font(.caption2)
                                    .foregroundColor(.expenseGreen)
                            }
                        }
                    } else {
                        Text("Base Currency")
                            .font(.caption)
                            .foregroundColor(.expenseAccent)
                            .fontWeight(.medium)
                    }

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.expenseGreen)
                    }
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.expenseGreen.opacity(0.1) : Color.clear)
        )
    }
}

struct CurrencySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySettingsView()
            .preferredColorScheme(.light)

        CurrencySettingsView()
            .preferredColorScheme(.dark)
    }
}

struct CurrencyCardView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            CurrencyCardView(
                currency: CurrencyManager.Currency.USD,
                isSelected: true,
                exchangeRate: 1.0
            ) { }

            CurrencyCardView(
                currency: CurrencyManager.Currency.MMK,
                isSelected: false,
                exchangeRate: 2100.0
            ) { }

            CurrencyCardView(
                currency: CurrencyManager.Currency.EUR,
                isSelected: false,
                exchangeRate: 0.85
            ) { }
        }
        .padding()
        .preferredColorScheme(.light)

        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            CurrencyCardView(
                currency: CurrencyManager.Currency.USD,
                isSelected: true,
                exchangeRate: 1.0
            ) { }

            CurrencyCardView(
                currency: CurrencyManager.Currency.MMK,
                isSelected: false,
                exchangeRate: 2100.0
            ) { }

            CurrencyCardView(
                currency: CurrencyManager.Currency.EUR,
                isSelected: false,
                exchangeRate: 0.85
            ) { }
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}
