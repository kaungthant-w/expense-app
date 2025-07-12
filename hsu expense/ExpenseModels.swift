// ExpenseModels.swift
import Foundation

// MARK: - ExpenseItem Model
struct ExpenseItem: Identifiable, Hashable {
    let id: UUID
    var name: String
    var price: Decimal
    var description: String
    var date: String
    var time: String
    var currency: String
    
    init(id: UUID = UUID(), name: String, price: Decimal, description: String, date: String, time: String, currency: String = "MMK") {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.date = date
        self.time = time
        self.currency = currency
    }
}

// MARK: - Dictionary Conversion
extension ExpenseItem {
    var asDictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "price": NSDecimalNumber(decimal: price).doubleValue,
            "description": description,
            "date": date,
            "time": time,
            "currency": currency
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> ExpenseItem? {
        guard let name = dict["name"] as? String,
              let description = dict["description"] as? String,
              let date = dict["date"] as? String,
              let time = dict["time"] as? String,
              let currency = dict["currency"] as? String else {
            return nil
        }
        
        let id: UUID
        if let idString = dict["id"] as? String, let uuid = UUID(uuidString: idString) {
            id = uuid
        } else {
            id = UUID()
        }
        
        let price: Decimal
        if let priceDouble = dict["price"] as? Double {
            price = Decimal(priceDouble)
        } else if let priceString = dict["price"] as? String, let priceValue = Decimal(string: priceString) {
            price = priceValue
        } else {
            price = 0
        }
        
        return ExpenseItem(
            id: id,
            name: name,
            price: price,
            description: description,
            date: date,
            time: time,
            currency: currency
        )
    }
}

// MARK: - UserDefaults Keys
struct ExpenseUserDefaultsKeys {
    static let expenses = "hsu_expenses"
    static let language = "hsu_language"
    static let theme = "hsu_theme"
    static let currency = "hsu_default_currency"
}

// MARK: - Date Formatters
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let displayTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

// MARK: - Currency Formatter
extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MMK"
        formatter.currencySymbol = "₭"
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - Sample Data Generator
extension ExpenseItem {
    static func generateSampleData(count: Int = 100) -> [ExpenseItem] {
        let myanmarExpenses = [
            "မနက်စာ", "နေ့လည်စာ", "ညစာ", "လက်ဖက်ရည်",
            "ကော်ဖီ", "ငါးလှော်", "ထမင်းကြီး", "မုန့်ဟင်းခါး",
            "ငှားခ", "လျှပ်စစ်ခ", "ရေခ", "ဖုန်းခ",
            "ဆီခ", "သယ်ယူခ", "အဝတ်အထည်", "ဆေးခ",
            "စာအုပ်", "ကားခ", "ဟင်းသီးဟင်းရွက်", "သီးနှံ",
            "အမဲသား", "ငါး", "ပန်းကန်", "ဒရမ်မာ",
            "ဖြတ်တောင်း", "လှေကား", "အိမ်ခြံ", "ပရိဘောဂ"
        ]
        
        let descriptions = [
            "နေ့စဉ် အသုံးအဆောင်",
            "အစားအသောက်",
            "အိမ်ထောင်ရေး ကုန်ကျမှု",
            "သယ်ယူပို့ဆောင်ရေး ကုန်ကျမှု",
            "ပညာရေး ကုန်ကျမှု",
            "ကျန်းမာရေး ကုန်ကျမှု",
            "အပတ်စဉ် စျေးဝယ်",
            "အရေးပေါ် ကုန်ကျမှု"
        ]
        
        var expenses: [ExpenseItem] = []
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<count {
            let randomDaysAgo = Int.random(in: 0...30)
            let expenseDate = calendar.date(byAdding: .day, value: -randomDaysAgo, to: now) ?? now
            
            let expense = ExpenseItem(
                name: myanmarExpenses.randomElement() ?? "အခြား",
                price: Decimal(Double.random(in: 500...50000)),
                description: descriptions.randomElement() ?? "အခြား ကုန်ကျမှု",
                date: DateFormatter.displayDate.string(from: expenseDate),
                time: DateFormatter.displayTime.string(from: expenseDate),
                currency: "MMK"
            )
            expenses.append(expense)
        }
        
        return expenses
    }
}
