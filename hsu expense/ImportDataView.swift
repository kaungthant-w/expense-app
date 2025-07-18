// ImportDataView.swift
import SwiftUI
import UniformTypeIdentifiers

struct ImportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFilePicker = false
    @State private var showImportAlert = false
    @State private var importError: String? = nil
    @State private var importSuccess = false
    @State private var importFileURL: URL? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                headerSection

                // Import instructions
                importInstructionsSection

                // Import button
                importButtonSection

                Spacer()
            }
            .padding(16)
            .navigationBarHidden(true)
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [
                .json,                                    // JSON files
                .commaSeparatedText,                      // CSV files
                .plainText,                               // TXT files
                UTType(filenameExtension: "xlsx") ?? .data, // Excel files
                UTType(filenameExtension: "xls") ?? .data   // Legacy Excel files
            ],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importFileURL = url
                    importExpenses(from: url)
                }
            case .failure(let error):
                importError = "Import failed: \(error.localizedDescription)"
                showImportAlert = true
            }
        }
        .alert(isPresented: $showImportAlert) {
            if let error = importError {
                return Alert(
                    title: Text("Import Error"),
                    message: Text(error),
                    dismissButton: .default(Text("OK")) {
                        importError = nil
                    }
                )
            } else {
                return Alert(
                    title: Text("Import Successful"),
                    message: Text("Your data has been imported successfully!"),
                    dismissButton: .default(Text("OK")) {
                        importSuccess = false
                        dismiss()
                    }
                )
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }

            Text("Import Data")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var importInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions")
                .font(.headline)
                .fontWeight(.bold)

            Text("• Select a JSON, CSV, or TXT file")
            Text("• CSV format: Name, Price, Description, Date [, Time] OR")
            Text("• Exported CSV: ID, Name, Price, Description, Date, Time, Currency")
            Text("• JSON format: HSU Expense export or array format")
            Text("• Existing data will be merged with imported data")
            Text("• Duplicate entries will be automatically handled")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private var importButtonSection: some View {
        Button(action: {
            showFilePicker = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)

                Text("Select File to Import")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
            )
        }
    }

    // MARK: - Import Functions
    private func importExpenses(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let fileExtension = url.pathExtension.lowercased()

            var importedExpenses: [ExpenseItem] = []

            switch fileExtension {
            case "json":
                importedExpenses = try parseJSONFile(data: data)
            case "csv":
                importedExpenses = try parseCSVFile(data: data)
            case "txt":
                importedExpenses = try parseTextFile(data: data)
            case "xlsx", "xls":
                importError = "Excel file import is not yet supported. Please export as CSV or JSON."
                showImportAlert = true
                return
            default:
                importError = "Unsupported file format: .\(fileExtension)"
                showImportAlert = true
                return
            }

            if importedExpenses.isEmpty {
                importError = "No valid expenses found in the file."
                showImportAlert = true
                return
            }

            // Merge imported expenses with existing data
            var existingExpenses = loadExpensesFromUserDefaults()

            // Avoid duplicates by checking IDs
            let existingIds = Set(existingExpenses.map { $0.id })
            let newExpenses = importedExpenses.filter { !existingIds.contains($0.id) }

            // Add new expenses to existing ones
            existingExpenses.append(contentsOf: newExpenses)

            // Save merged expenses
            let mergedArray = existingExpenses.map { $0.asDictionary }
            UserDefaults.standard.set(mergedArray, forKey: ExpenseUserDefaultsKeys.expenses)

            // Notify ContentView to reload data
            NotificationCenter.default.post(name: NSNotification.Name("ReloadExpensesFromUserDefaults"), object: nil)

            importSuccess = true
            importError = nil
            showImportAlert = true

        } catch {
            importError = "Failed to read file: \(error.localizedDescription)"
            showImportAlert = true
        }
    }

    private func parseJSONFile(data: Data) throws -> [ExpenseItem] {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Check if it's HSU Expense format
        if let expensesArray = json?["expenses"] as? [[String: Any]] {
            return expensesArray.compactMap { ExpenseItem.fromDictionary($0) }
        }

        // Try parsing as array of expense objects
        if let expensesArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            return expensesArray.compactMap { ExpenseItem.fromDictionary($0) }
        }

        throw ImportError.invalidFormat
    }

    private func parseCSVFile(data: Data) throws -> [ExpenseItem] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidEncoding
        }

        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard lines.count > 1 else {
            throw ImportError.invalidFormat
        }

        // Skip header row
        var expenses: [ExpenseItem] = []

        for line in lines.dropFirst() {
            let components = parseCSVRow(line)

            // Handle both formats: exported format (7 columns) and simple format (4-5 columns)
            if components.count >= 7 {
                // Exported CSV format: ID,Name,Price,Description,Date,Time,Currency
                let id = components[0].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let name = components[1].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let priceString = components[2].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let description = components[3].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let dateString = components[4].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let timeString = components[5].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let currency = components[6].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))

                guard let price = Decimal(string: priceString) else { continue }

                let expenseId = UUID(uuidString: id) ?? UUID()
                let expense = ExpenseItem(
                    id: expenseId,
                    name: name,
                    price: price,
                    description: description,
                    date: dateString,
                    time: timeString,
                    currency: currency
                )
                expenses.append(expense)

            } else if components.count >= 4 {
                // Simple CSV format: Name,Price,Description,Date[,Time]
                let name = components[0].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let priceString = components[1].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let description = components[2].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let dateString = components[3].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))

                // Check if time is included in CSV (5th column)
                let timeString = components.count > 4 ?
                    components[4].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"")) :
                    "12:00 PM"

                guard let price = Decimal(string: priceString) else { continue }

                let expense = ExpenseItem(
                    name: name,
                    price: price,
                    description: description,
                    date: dateString,
                    time: timeString
                )
                expenses.append(expense)
            }
        }

        return expenses
    }

    private func parseTextFile(data: Data) throws -> [ExpenseItem] {
        // Try JSON first
        do {
            return try parseJSONFile(data: data)
        } catch {
            // Try CSV format
            do {
                return try parseCSVFile(data: data)
            } catch {
                throw ImportError.invalidFormat
            }
        }
    }

    private func parseCSVRow(_ row: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var insideQuotes = false

        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                components.append(currentComponent)
                currentComponent = ""
            } else {
                currentComponent.append(char)
            }
        }

        // Add the last component
        components.append(currentComponent)

        return components
    }

    private func loadExpensesFromUserDefaults() -> [ExpenseItem] {
        guard let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] else {
            return []
        }
        return dictArray.compactMap { ExpenseItem.fromDictionary($0) }
    }
}

enum ImportError: Error {
    case invalidFormat
    case invalidEncoding
}
