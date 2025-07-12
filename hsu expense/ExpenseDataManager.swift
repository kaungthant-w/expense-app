// ExpenseDataManager.swift
import SwiftUI
import Foundation

class ExpenseDataManager: ObservableObject {
    static let shared = ExpenseDataManager()
    
    private init() {}
    
    // MARK: - Export Functions
    func exportExpensesToJSON() -> String? {
        guard let expenses = loadExpensesFromUserDefaults() else {
            return nil
        }
        
        let exportData: [String: Any] = [
            "app_name": "HSU Expense",
            "export_version": "1.0",
            "export_date": DateFormatter.iso8601.string(from: Date()),
            "expenses": expenses.map { $0.asDictionary },
            "total_expenses": expenses.count
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error exporting to JSON: \(error)")
            return nil
        }
    }
    
    func exportExpensesToCSV() -> String? {
        guard let expenses = loadExpensesFromUserDefaults() else {
            return nil
        }
        
        var csvString = "ID,Name,Price,Description,Date,Time,Currency\n"
        
        for expense in expenses {
            let row = [
                expense.id.uuidString,
                expense.name.replacingOccurrences(of: ",", with: ";"), // Escape commas
                String(format: "%.2f", NSDecimalNumber(decimal: expense.price).doubleValue),
                expense.description.replacingOccurrences(of: ",", with: ";"), // Escape commas
                expense.date,
                expense.time,
                expense.currency
            ].joined(separator: ",")
            
            csvString += row + "\n"
        }
        
        return csvString
    }
    
    // MARK: - Import Functions
    func importExpensesFromJSON(_ jsonString: String) -> Bool {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return false
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let expensesArray = json["expenses"] as? [[String: Any]] {
                
                var importedExpenses: [ExpenseItem] = []
                
                for expenseDict in expensesArray {
                    if let expense = ExpenseItem.fromDictionary(expenseDict) {
                        importedExpenses.append(expense)
                    }
                }
                
                // Merge with existing expenses
                var existingExpenses = loadExpensesFromUserDefaults() ?? []
                existingExpenses.append(contentsOf: importedExpenses)
                
                return saveExpensesToUserDefaults(existingExpenses)
            }
        } catch {
            print("Error importing JSON: \(error)")
        }
        
        return false
    }
    
    // MARK: - UserDefaults Helper Functions
    private func loadExpensesFromUserDefaults() -> [ExpenseItem]? {
        guard let data = UserDefaults.standard.data(forKey: ExpenseUserDefaultsKeys.expenses) else {
            return []
        }
        
        do {
            let expenses = try JSONDecoder().decode([ExpenseItem].self, from: data)
            return expenses
        } catch {
            // Fallback to dictionary format
            if let expensesDictArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return expensesDictArray.compactMap { ExpenseItem.fromDictionary($0) }
            }
            print("Error loading expenses: \(error)")
            return []
        }
    }
    
    private func saveExpensesToUserDefaults(_ expenses: [ExpenseItem]) -> Bool {
        do {
            let data = try JSONEncoder().encode(expenses)
            UserDefaults.standard.set(data, forKey: ExpenseUserDefaultsKeys.expenses)
            return true
        } catch {
            print("Error saving expenses: \(error)")
            return false
        }
    }
}

// MARK: - ExpenseItem Codable Support
extension ExpenseItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, price, description, date, time, currency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Decimal.self, forKey: .price)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(String.self, forKey: .date)
        time = try container.decode(String.self, forKey: .time)
        currency = try container.decode(String.self, forKey: .currency)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(time, forKey: .time)
        try container.encode(currency, forKey: .currency)
    }
}
