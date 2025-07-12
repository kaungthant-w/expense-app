//
//  EnhancedImportDataView.swift
//  HSU Expense
//
//  Created by GitHub Copilot on 7/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct EnhancedImportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFile: URL?
    @State private var isImporting = false
    @State private var importSuccess = false
    @State private var importError: String?
    @State private var previewExpenses: [ExpenseItem] = []
    @State private var showingFilePicker = false
    @State private var importMode: ImportMode = .merge
    @State private var duplicateHandling: DuplicateHandling = .skip
    @State private var importedCount = 0
    @State private var skippedCount = 0

    enum ImportMode: String, CaseIterable {
        case merge = "Merge"
        case replace = "Replace All"

        var icon: String {
            switch self {
            case .merge: return "plus.circle"
            case .replace: return "arrow.clockwise.circle"
            }
        }

        var description: String {
            switch self {
            case .merge: return "Add to existing expenses"
            case .replace: return "Replace all current expenses"
            }
        }
    }

    enum DuplicateHandling: String, CaseIterable {
        case skip = "Skip"
        case replace = "Replace"
        case duplicate = "Allow Duplicates"

        var icon: String {
            switch self {
            case .skip: return "xmark.circle"
            case .replace: return "arrow.triangle.2.circlepath"
            case .duplicate: return "doc.on.doc"
            }
        }

        var description: String {
            switch self {
            case .skip: return "Skip duplicate entries"
            case .replace: return "Replace existing duplicates"
            case .duplicate: return "Import all entries"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard

                    // File Selection Card
                    fileSelectionCard

                    // Import Options (only show if file is selected)
                    if selectedFile != nil {
                        importOptionsCard
                    }

                    // Preview Card (only show if we have preview data)
                    if !previewExpenses.isEmpty {
                        previewCard
                    }

                    // Import Button (only show if file is selected)
                    if selectedFile != nil {
                        importButton
                    }
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.expenseAccent)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json, .commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .alert("Import Error", isPresented: .constant(importError != nil)) {
                Button("OK") {
                    importError = nil
                }
            } message: {
                Text(importError ?? "")
            }
            .alert("Import Successful", isPresented: $importSuccess) {
                Button("OK") {
                    importSuccess = false
                    dismiss()
                }
            } message: {
                Text("Successfully imported \(importedCount) expenses. \(skippedCount > 0 ? "Skipped \(skippedCount) duplicates." : "")")
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.expenseAccent.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .foregroundColor(.expenseAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Import Your Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)

                    Text("Upload expenses from JSON, CSV, or text files")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()
            }

            // Supported formats info
            VStack(alignment: .leading, spacing: 8) {
                Text("Supported Formats:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.expenseSecondaryText)

                HStack(spacing: 16) {
                    ForEach(["JSON", "CSV", "TXT"], id: \.self) { format in
                        HStack(spacing: 4) {
                            Image(systemName: formatIcon(format))
                                .font(.caption)
                                .foregroundColor(.expenseAccent)
                            Text(format)
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.expenseInputBackground)
                        )
                    }

                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - File Selection Card
    private var fileSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "doc.badge.plus")
                    .foregroundColor(.expenseAccent)
                Text("Select File")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            if let selectedFile = selectedFile {
                // Selected file display
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.fill")
                            .font(.title2)
                            .foregroundColor(.expenseAccent)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedFile.lastPathComponent)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.expensePrimaryText)

                            Text(fileTypeDescription(selectedFile))
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)
                        }

                        Spacer()

                        Button("Change") {
                            showingFilePicker = true
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.expenseAccent)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.expenseAccent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.expenseAccent, lineWidth: 1)
                            )
                    )
                }
            } else {
                // File picker button
                Button(action: {
                    showingFilePicker = true
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.expenseAccent)

                        VStack(spacing: 8) {
                            Text("Choose File to Import")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.expensePrimaryText)

                            Text("Tap to browse and select your expense data file")
                                .font(.subheadline)
                                .foregroundColor(.expenseSecondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.expenseInputBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.expenseCardBorder, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Import Options Card
    private var importOptionsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "gear")
                    .foregroundColor(.expenseAccent)
                Text("Import Options")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            // Import Mode Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Import Mode")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.expenseSecondaryText)

                VStack(spacing: 8) {
                    ForEach(ImportMode.allCases, id: \.self) { mode in
                        importModeRow(mode)
                    }
                }
            }

            // Duplicate Handling (only show in merge mode)
            if importMode == .merge {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duplicate Handling")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.expenseSecondaryText)

                    VStack(spacing: 8) {
                        ForEach(DuplicateHandling.allCases, id: \.self) { handling in
                            duplicateHandlingRow(handling)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func importModeRow(_ mode: ImportMode) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                importMode = mode
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16))
                    .foregroundColor(importMode == mode ? .expenseAccent : .expenseSecondaryText)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)

                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()

                Image(systemName: importMode == mode ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(importMode == mode ? .expenseAccent : .expenseSecondaryText)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(importMode == mode ? Color.expenseAccent.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(importMode == mode ? Color.expenseAccent : Color.expenseCardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func duplicateHandlingRow(_ handling: DuplicateHandling) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                duplicateHandling = handling
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: handling.icon)
                    .font(.system(size: 16))
                    .foregroundColor(duplicateHandling == handling ? .expenseAccent : .expenseSecondaryText)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(handling.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)

                    Text(handling.description)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()

                Image(systemName: duplicateHandling == handling ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(duplicateHandling == handling ? .expenseAccent : .expenseSecondaryText)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(duplicateHandling == handling ? Color.expenseAccent.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(duplicateHandling == handling ? Color.expenseAccent : Color.expenseCardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "eye")
                    .foregroundColor(.expenseAccent)
                Text("Preview (\(previewExpenses.count) expenses)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 8) {
                // Show first few expenses as preview
                ForEach(Array(previewExpenses.prefix(3))) { expense in
                    previewExpenseRow(expense)
                }

                if previewExpenses.count > 3 {
                    Text("... and \(previewExpenses.count - 3) more expenses")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func previewExpenseRow(_ expense: ExpenseItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.expensePrimaryText)
                    .lineLimit(1)

                Text("\(expense.formattedDate) • \(expense.formattedTime)")
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
            }

            Spacer()

            Text(expense.formattedPrice)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.expenseGreen)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.expenseInputBackground)
        )
    }

    // MARK: - Import Button
    private var importButton: some View {
        Button(action: performImport) {
            HStack(spacing: 12) {
                if isImporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title3)
                }

                Text(isImporting ? "Importing..." : "Import \(previewExpenses.count) Expenses")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(previewExpenses.isEmpty ? Color.expenseSecondaryText : Color.expenseAccent)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(previewExpenses.isEmpty || isImporting)
    }

    // MARK: - Helper Methods
    private func formatIcon(_ format: String) -> String {
        switch format {
        case "JSON": return "doc.text"
        case "CSV": return "tablecells"
        case "TXT": return "doc.plaintext"
        default: return "doc"
        }
    }

    private func fileTypeDescription(_ url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "json": return "JSON Document"
        case "csv": return "CSV Spreadsheet"
        case "txt": return "Text Document"
        default: return "Document"
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                selectedFile = url
                parseFile(url)
            }
        case .failure(let error):
            importError = "Failed to select file: \(error.localizedDescription)"
        }
    }

    private func parseFile(_ url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let fileExtension = url.pathExtension.lowercased()

            switch fileExtension {
            case "json":
                parseJSONData(data)
            case "csv":
                parseCSVData(data)
            case "txt":
                parseTextData(data)
            default:
                importError = "Unsupported file format: \(fileExtension)"
            }
        } catch {
            importError = "Failed to read file: \(error.localizedDescription)"
        }
    }

    private func parseJSONData(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // HSU Expense format
                if let expensesArray = json["expenses"] as? [[String: Any]] {
                    previewExpenses = expensesArray.compactMap { ExpenseItem.fromDictionary($0) }
                } else {
                    importError = "Invalid JSON format: missing 'expenses' array"
                }
            } else if let expensesArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                // Direct array format
                previewExpenses = expensesArray.compactMap { ExpenseItem.fromDictionary($0) }
            } else {
                importError = "Invalid JSON format"
            }
        } catch {
            importError = "Failed to parse JSON: \(error.localizedDescription)"
        }
    }

    private func parseCSVData(_ data: Data) {
        guard let content = String(data: data, encoding: .utf8) else {
            importError = "Failed to read CSV file"
            return
        }

        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else {
            importError = "CSV file appears to be empty"
            return
        }

        // Skip header row and parse data rows
        let dataLines = Array(lines.dropFirst())
        var expenses: [ExpenseItem] = []

        for line in dataLines {
            if let expense = parseCSVLine(line) {
                expenses.append(expense)
            }
        }

        previewExpenses = expenses
    }

    private func parseCSVLine(_ line: String) -> ExpenseItem? {
        let components = parseCSVRow(line)
        guard components.count >= 7 else { return nil }

        guard let id = UUID(uuidString: components[0]),
              let price = Double(components[2]) else { return nil }

        let name = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let description = components[3].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let currency = components[6]

        // Parse date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: components[4]) else { return nil }

        dateFormatter.dateFormat = "HH:mm:ss"
        guard let time = dateFormatter.date(from: components[5]) else { return nil }

        return ExpenseItem(
            id: id,
            name: name,
            price: Decimal(price),
            description: description,
            date: date,
            time: time,
            currency: currency
        )
    }

    private func parseCSVRow(_ row: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var insideQuotes = false
        var i = row.startIndex

        while i < row.endIndex {
            let char = row[i]

            if char == "\"" {
                if insideQuotes && i < row.index(before: row.endIndex) && row[row.index(after: i)] == "\"" {
                    // Escaped quote
                    currentComponent += "\""
                    i = row.index(after: i)
                } else {
                    insideQuotes.toggle()
                }
            } else if char == "," && !insideQuotes {
                components.append(currentComponent)
                currentComponent = ""
            } else {
                currentComponent += String(char)
            }

            i = row.index(after: i)
        }

        components.append(currentComponent)
        return components
    }

    private func parseTextData(_ data: Data) {
        guard let content = String(data: data, encoding: .utf8) else {
            importError = "Failed to read text file"
            return
        }

        // Simple text parsing - look for expense patterns
        let lines = content.components(separatedBy: .newlines)
        var expenses: [ExpenseItem] = []

        for line in lines {
            if let expense = parseTextLine(line) {
                expenses.append(expense)
            }
        }

        previewExpenses = expenses
    }

    private func parseTextLine(_ line: String) -> ExpenseItem? {
        // Simple pattern matching for text format
        // Example: "1. Coffee Shop - $5.50 - 2025-07-12 at 09:30"
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLine.isEmpty else { return nil }

        // Skip header lines and separators
        if trimmedLine.hasPrefix("HSU Expense") || trimmedLine.hasPrefix("Export Date") ||
           trimmedLine.hasPrefix("Total Expenses") || trimmedLine.contains("====") {
            return nil
        }

        // Look for numbered entries
        let numberPattern = #"^\d+\.\s*(.+)"#
        guard let regex = try? NSRegularExpression(pattern: numberPattern) else { return nil }

        let range = NSRange(trimmedLine.startIndex..., in: trimmedLine)
        guard let match = regex.firstMatch(in: trimmedLine, range: range) else { return nil }

        let nameRange = Range(match.range(at: 1), in: trimmedLine)!
        let name = String(trimmedLine[nameRange])

        // Create a basic expense item (you might want to enhance this parsing)
        return ExpenseItem(
            name: name,
            price: 0, // Would need more sophisticated parsing for price
            description: "",
            date: Date(),
            time: Date(),
            currency: "USD"
        )
    }

    private func performImport() {
        guard !previewExpenses.isEmpty else { return }

        isImporting = true
        importedCount = 0
        skippedCount = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                try processImport()
                importSuccess = true
            } catch {
                importError = error.localizedDescription
            }
            isImporting = false
        }
    }

    private func processImport() throws {
        // Load existing expenses
        let existingExpensesDict = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] ?? []
        var existingExpenses = existingExpensesDict.compactMap { ExpenseItem.fromDictionary($0) }

        if importMode == .replace {
            // Replace all expenses
            existingExpenses = previewExpenses
            importedCount = previewExpenses.count
        } else {
            // Merge mode
            for expense in previewExpenses {
                let isDuplicate = existingExpenses.contains { existing in
                    existing.name == expense.name &&
                    existing.price == expense.price &&
                    Calendar.current.isDate(existing.date, inSameDayAs: expense.date)
                }

                if isDuplicate {
                    switch duplicateHandling {
                    case .skip:
                        skippedCount += 1
                    case .replace:
                        if let index = existingExpenses.firstIndex(where: { existing in
                            existing.name == expense.name &&
                            existing.price == expense.price &&
                            Calendar.current.isDate(existing.date, inSameDayAs: expense.date)
                        }) {
                            existingExpenses[index] = expense
                            importedCount += 1
                        }
                    case .duplicate:
                        existingExpenses.append(expense)
                        importedCount += 1
                    }
                } else {
                    existingExpenses.append(expense)
                    importedCount += 1
                }
            }
        }

        // Save to UserDefaults
        let dictArray = existingExpenses.map { $0.asDictionary }
        UserDefaults.standard.set(dictArray, forKey: ExpenseUserDefaultsKeys.expenses)

        // Notify the main view to reload
        NotificationCenter.default.post(name: NSNotification.Name("ReloadExpensesFromUserDefaults"), object: nil)
    }
}

// MARK: - Preview
struct EnhancedImportDataView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedImportDataView()
            .preferredColorScheme(.light)

        EnhancedImportDataView()
            .preferredColorScheme(.dark)
    }
}
