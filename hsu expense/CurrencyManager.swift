import Foundation
import SwiftUI

class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()

    @Published var currentCurrency: Currency = .USD
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isUpdatingRates: Bool = false

    private let userDefaults = UserDefaults.standard
    private let currencyKey = "selected_currency"
    private let ratesKey = "exchange_rates"
    private let lastUpdateKey = "rates_last_update"

    struct Currency: Identifiable, Codable {
        var id: String { code } // Use code as id for Codable compatibility
        let code: String
        let symbol: String
        let name: String
        let flag: String

        static let USD = Currency(code: "USD", symbol: "$", name: "US Dollar", flag: "🇺🇸")
        static let MMK = Currency(code: "MMK", symbol: "K", name: "Myanmar Kyat", flag: "🇲🇲")
        static let EUR = Currency(code: "EUR", symbol: "€", name: "Euro", flag: "🇪🇺")
        static let JPY = Currency(code: "JPY", symbol: "¥", name: "Japanese Yen", flag: "🇯🇵")
        static let GBP = Currency(code: "GBP", symbol: "£", name: "British Pound", flag: "🇬🇧")
        static let CNY = Currency(code: "CNY", symbol: "¥", name: "Chinese Yuan", flag: "🇨🇳")
        static let KRW = Currency(code: "KRW", symbol: "₩", name: "Korean Won", flag: "🇰🇷")
        static let THB = Currency(code: "THB", symbol: "฿", name: "Thai Baht", flag: "🇹🇭")
        static let SGD = Currency(code: "SGD", symbol: "S$", name: "Singapore Dollar", flag: "🇸🇬")
        static let INR = Currency(code: "INR", symbol: "₹", name: "Indian Rupee", flag: "🇮🇳")

        static let allCurrencies = [USD, MMK, EUR, JPY, GBP, CNY, KRW, THB, SGD, INR]
    }

    private init() {
        loadSelectedCurrency()
        loadExchangeRates()

        // Auto-update rates if they're more than 1 hour old
        if shouldAutoUpdateRates() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.updateExchangeRates()
            }
        }
    }

    private func shouldAutoUpdateRates() -> Bool {
        guard let lastUpdate = lastUpdateDate else { return true }
        let oneHourAgo = Date().addingTimeInterval(-3600) // 1 hour ago
        return lastUpdate < oneHourAgo
    }

    // MARK: - Currency Selection
    func setCurrency(_ currency: Currency) {
        currentCurrency = currency
        userDefaults.set(currency.code, forKey: currencyKey)
        NotificationCenter.default.post(name: .currencyChanged, object: currency)
    }

    // MARK: - Exchange Rate Management
    func updateExchangeRates() {
        isUpdatingRates = true

        // Fetch real exchange rates from Myanmar Currency API
        fetchExchangeRatesFromAPI()
    }    private func fetchExchangeRatesFromAPI() {
        // Use Myanmar Currency API as primary source
        let apiUrls = [
            "https://myanmar-currency-api.github.io/api/latest.json",
            "https://api.exchangerate-api.com/v4/latest/USD",
            "https://open.er-api.com/v6/latest/USD"
        ]

        fetchFromMultipleAPIs(urls: apiUrls, currentIndex: 0)
    }

    private func fetchFromMultipleAPIs(urls: [String], currentIndex: Int) {
        guard currentIndex < urls.count else {
            // All APIs failed, use fallback
            handleAPIError("All exchange rate APIs are unavailable")
            return
        }

        guard let url = URL(string: urls[currentIndex]) else {
            // Try next API
            fetchFromMultipleAPIs(urls: urls, currentIndex: currentIndex + 1)
            return
        }

        print("🔄 Trying API \(currentIndex + 1): \(urls[currentIndex])")

        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0 // 10 seconds timeout
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("❌ API \(currentIndex + 1) failed: \(error.localizedDescription)")
                    // Try next API
                    self.fetchFromMultipleAPIs(urls: urls, currentIndex: currentIndex + 1)
                    return
                }

                guard let data = data else {
                    print("❌ API \(currentIndex + 1) returned no data")
                    // Try next API
                    self.fetchFromMultipleAPIs(urls: urls, currentIndex: currentIndex + 1)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📡 API \(currentIndex + 1) response: \(json)")

                        // Handle different API response formats
                        var rates: [String: Double]?

                        // Format 1: Myanmar Currency API format
                        if currentIndex == 0, let dataArray = json["data"] as? [[String: Any]] {
                            print("🇲🇲 Processing Myanmar Currency API data")
                            rates = processMyanmarCurrencyAPI(dataArray: dataArray)
                        }
                        // Format 2: Standard exchange rate APIs
                        else if let directRates = json["rates"] as? [String: Double] {
                            rates = directRates
                        }
                        // Format 3: Conversion rates format
                        else if let conversionRates = json["conversion_rates"] as? [String: Double] {
                            rates = conversionRates
                        }

                        guard let apiRates = rates else {
                            print("❌ API \(currentIndex + 1) has invalid format")
                            // Try next API
                            self.fetchFromMultipleAPIs(urls: urls, currentIndex: currentIndex + 1)
                            return
                        }

                        // Process the rates from the API
                        var processedRates: [String: Double] = [:]

                        // USD is base currency (rate = 1.0)
                        processedRates["USD"] = 1.0

                        // Map API rates to our currency codes
                        let supportedCurrencies = ["MMK", "EUR", "JPY", "GBP", "CNY", "KRW", "THB", "SGD", "INR"]

                        for currencyCode in supportedCurrencies {
                            if let rate = apiRates[currencyCode] {
                                processedRates[currencyCode] = rate
                            }
                        }

                        // Add fallback rates for any missing currencies
                        let fallbackRates: [String: Double] = [
                            "USD": 1.0,
                            "MMK": 2100.0,
                            "EUR": 0.85,
                            "JPY": 150.0,
                            "GBP": 0.79,
                            "CNY": 7.25,
                            "KRW": 1340.0,
                            "THB": 36.0,
                            "SGD": 1.35,
                            "INR": 83.0
                        ]

                        // Merge with fallback rates for missing currencies
                        for (currency, fallbackRate) in fallbackRates {
                            if processedRates[currency] == nil {
                                processedRates[currency] = fallbackRate
                                print("⚠️ Using fallback rate for \(currency)")
                            }
                        }

                        // Update the exchange rates
                        self.exchangeRates = processedRates
                        self.userDefaults.set(Date(), forKey: self.lastUpdateKey)

                        if let data = try? JSONEncoder().encode(processedRates) {
                            self.userDefaults.set(data, forKey: self.ratesKey)
                        }

                        self.isUpdatingRates = false
                        NotificationCenter.default.post(name: .exchangeRatesUpdated, object: nil)

                        print("✅ Exchange rates updated successfully from API \(currentIndex + 1)")
                        print("📊 Current rates: \(processedRates)")

                        return // Success, don't try other APIs

                    } else {
                        print("❌ API \(currentIndex + 1) returned invalid JSON")
                        // Try next API
                        self.fetchFromMultipleAPIs(urls: urls, currentIndex: currentIndex + 1)
                    }

                } catch {
                    print("❌ API \(currentIndex + 1) JSON parsing error: \(error.localizedDescription)")
                    // Try next API
                    self.fetchFromMultipleAPIs(urls: urls, currentIndex: currentIndex + 1)
                }
            }
        }

        task.resume()
    }

    // MARK: - Myanmar Currency API Processing
    private func processMyanmarCurrencyAPI(dataArray: [[String: Any]]) -> [String: Double] {
        var rates: [String: Double] = [:]

        // USD is always 1.0 as base currency
        rates["USD"] = 1.0

        // First pass: get USD to MMK rate
        var usdToMmkRate: Double?
        for currencyData in dataArray {
            if let currencyCode = currencyData["currency"] as? String,
               currencyCode == "USD",
               let sellString = currencyData["sell"] as? String {
                usdToMmkRate = parseRate(from: sellString)
                break
            }
        }

        // Set MMK rate directly from USD
        if let mmkRate = usdToMmkRate {
            rates["MMK"] = mmkRate
            print("🇲🇲 USD to MMK rate: \(mmkRate)")
        }

        // Second pass: process other currencies
        for currencyData in dataArray {
            guard let currencyCode = currencyData["currency"] as? String,
                  let sellString = currencyData["sell"] as? String,
                  currencyCode != "USD" else {
                continue
            }

            // Map currency codes to our supported currencies
            let mappedCode = mapMyanmarCurrencyCode(currencyCode)

            // Parse sell rate
            if let sellRate = parseRate(from: sellString),
               let usdRate = usdToMmkRate {

                // Convert: if 1 EUR = 4685 MMK and 1 USD = 4380 MMK
                // Then 1 USD = (4380/4685) EUR
                let usdToCurrencyRate = usdRate / sellRate
                rates[mappedCode] = usdToCurrencyRate

                print("🔄 \(currencyCode) (\(mappedCode)): 1 USD = \(usdToCurrencyRate)")
            }
        }

        print("🇲🇲 Final processed Myanmar API rates: \(rates)")
        return rates
    }

    private func parseRate(from rateString: String) -> Double? {
        // Remove any trailing dots and whitespace, then parse
        var cleanedString = rateString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove trailing dot if present
        if cleanedString.hasSuffix(".") {
            cleanedString = String(cleanedString.dropLast())
        }

        return Double(cleanedString)
    }

    private func mapMyanmarCurrencyCode(_ code: String) -> String {
        switch code {
        case "USD": return "USD"
        case "EUR": return "EUR"
        case "SGD": return "SGD"
        case "CNY": return "CNY"
        case "THB": return "THB"
        case "JPN": return "JPY" // Map JPN to JPY
        case "MYR": return "MYR" // Malaysian Ringgit (not in our main currencies but we can handle it)
        default: return code
        }
    }

    private func getRateFromDataArray(_ dataArray: [[String: Any]], currency: String) -> Double? {
        for currencyData in dataArray {
            if let currencyCode = currencyData["currency"] as? String,
               currencyCode == currency,
               let sellString = currencyData["sell"] as? String {
                return parseRate(from: sellString)
            }
        }
        return nil
    }

    private func handleAPIError(_ message: String) {
        print("❌ API Error: \(message)")

        // Use fallback rates if API fails
        let fallbackRates: [String: Double] = [
            "USD": 1.0,
            "MMK": 2100.0,
            "EUR": 0.85,
            "JPY": 150.0,
            "GBP": 0.79,
            "CNY": 7.25,
            "KRW": 1340.0,
            "THB": 36.0,
            "SGD": 1.35,
            "INR": 83.0
        ]

        exchangeRates = fallbackRates
        userDefaults.set(Date(), forKey: lastUpdateKey)

        if let data = try? JSONEncoder().encode(fallbackRates) {
            userDefaults.set(data, forKey: ratesKey)
        }

        isUpdatingRates = false
        NotificationCenter.default.post(name: .exchangeRatesUpdated, object: nil)

        // Post error notification for UI feedback
        NotificationCenter.default.post(
            name: .exchangeRatesFailed,
            object: nil,
            userInfo: ["error": message]
        )
    }

    // MARK: - Currency Conversion
    func convertAmount(_ amount: Double, from: String, to: String) -> Double {
        guard from != to else { return amount }

        // Convert to USD first (base currency)
        let usdAmount: Double
        if from == "USD" {
            usdAmount = amount
        } else {
            guard let fromRate = exchangeRates[from] else { return amount }
            usdAmount = amount / fromRate
        }

        // Convert from USD to target currency
        if to == "USD" {
            return usdAmount
        } else {
            guard let toRate = exchangeRates[to] else { return amount }
            return usdAmount * toRate
        }
    }

    func convertDecimalAmount(_ amount: Decimal, from: String, to: String) -> Decimal {
        let doubleAmount = NSDecimalNumber(decimal: amount).doubleValue
        let convertedAmount = convertAmount(doubleAmount, from: from, to: to)
        return Decimal(convertedAmount)
    }

    func formatAmount(_ amount: Double, currency: Currency? = nil) -> String {
        let selectedCurrency = currency ?? currentCurrency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.code
        formatter.currencySymbol = selectedCurrency.symbol
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency.symbol)\(String(format: "%.2f", amount))"
    }

    func formatDecimalAmount(_ amount: Decimal, currency: Currency? = nil) -> String {
        let doubleAmount = NSDecimalNumber(decimal: amount).doubleValue
        return formatAmount(doubleAmount, currency: currency)
    }

    var lastUpdateDate: Date? {
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }

    var lastUpdateString: String {
        guard let date = lastUpdateDate else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Private Methods
    private func loadSelectedCurrency() {
        let savedCode = userDefaults.string(forKey: currencyKey) ?? "USD"
        currentCurrency = Currency.allCurrencies.first { $0.code == savedCode } ?? .USD
    }

    private func loadExchangeRates() {
        guard let data = userDefaults.data(forKey: ratesKey),
              let rates = try? JSONDecoder().decode([String: Double].self, from: data) else {
            // Default rates
            exchangeRates = [
                "USD": 1.0,
                "MMK": 2100.0,
                "EUR": 0.85,
                "JPY": 150.0,
                "GBP": 0.79,
                "CNY": 7.25,
                "KRW": 1340.0,
                "THB": 36.0,
                "SGD": 1.35,
                "INR": 83.0
            ]
            return
        }
        exchangeRates = rates
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let currencyChanged = Notification.Name("currencyChanged")
    static let exchangeRatesUpdated = Notification.Name("exchangeRatesUpdated")
    static let exchangeRatesFailed = Notification.Name("exchangeRatesFailed")
}
