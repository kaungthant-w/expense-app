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
        let id = UUID()
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
    }
    
    private func fetchExchangeRatesFromAPI() {
        guard let url = URL(string: "https://myanmar-currency-api.github.io/api/latest.json") else {
            handleAPIError("Invalid API URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.handleAPIError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.handleAPIError("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let rates = json["rates"] as? [String: Double] {
                        
                        // Process the rates from the API
                        var processedRates: [String: Double] = [:]
                        
                        // USD is base currency (rate = 1.0)
                        processedRates["USD"] = 1.0
                        
                        // Map API rates to our currency codes
                        if let mmkRate = rates["MMK"] {
                            processedRates["MMK"] = mmkRate
                        }
                        if let eurRate = rates["EUR"] {
                            processedRates["EUR"] = eurRate
                        }
                        if let jpyRate = rates["JPY"] {
                            processedRates["JPY"] = jpyRate
                        }
                        if let gbpRate = rates["GBP"] {
                            processedRates["GBP"] = gbpRate
                        }
                        if let cnyRate = rates["CNY"] {
                            processedRates["CNY"] = cnyRate
                        }
                        if let krwRate = rates["KRW"] {
                            processedRates["KRW"] = krwRate
                        }
                        if let thbRate = rates["THB"] {
                            processedRates["THB"] = thbRate
                        }
                        if let sgdRate = rates["SGD"] {
                            processedRates["SGD"] = sgdRate
                        }
                        if let inrRate = rates["INR"] {
                            processedRates["INR"] = inrRate
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
                        
                        // Merge with fallback rates
                        for (currency, fallbackRate) in fallbackRates {
                            if processedRates[currency] == nil {
                                processedRates[currency] = fallbackRate
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
                        
                        print("✅ Exchange rates updated successfully from Myanmar Currency API")
                        print("📊 MMK Rate: \(processedRates["MMK"] ?? 0)")
                        
                    } else {
                        self.handleAPIError("Invalid JSON format")
                    }
                    
                } catch {
                    self.handleAPIError("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
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
