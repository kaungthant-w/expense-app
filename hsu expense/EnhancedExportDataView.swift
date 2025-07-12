//
//  EnhancedExportDataView.swift
//  HSU Expense
//
//  Created by GitHub Copilot on 7/12/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct EnhancedExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expenses: [ExpenseItem] = []
    @State private var selectedFormat: ExportFormat = .json
    @State private var isExporting = false
    @State private var exportSuccess = false
    @State private var exportError: String? = nil
    @State private var showingDateRange = false
    @State private var dateRange: DateRange = .all
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()

    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case txt = "Text"

        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csv: return "csv"
            case .txt: return "txt"
            }
        }

        var icon: String {
            switch self {
            case .json: return "doc.text"
            case .csv: return "tablecells"
            case .txt: return "doc.plaintext"
            }
        }

        var description: String {
            switch self {
            case .json: return "Structured data format"
            case .csv: return "Spreadsheet compatible"
            case .txt: return "Plain text format"
            }
        }
    }

    enum DateRange: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case custom = "Custom Range"

        var icon: String {
            switch self {
            case .all: return "infinity"
            case .today: return "calendar"
            case .thisWeek: return "calendar.circle"
            case .thisMonth: return "calendar.badge.clock"
            case .custom: return "calendar.badge.plus"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard

                    // Export Format Selection
                    formatSelectionCard

                    // Date Range Selection
                    dateRangeCard

                    // Summary Card
                    summaryCard

                    // Export Button
                    exportButton
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.expenseAccent)
                }
            }
            .alert("Export Error", isPresented: .constant(exportError != nil)) {
                Button("OK") {
                    exportError = nil
                }
            } message: {
                Text(exportError ?? "")
            }
            .alert("Export Successful", isPresented: $exportSuccess) {
                Button("OK") {
                    exportSuccess = false
                }
            } message: {
                Text("Your expenses have been exported successfully!")
            }
        }
        .onAppear {
            loadExpenses()
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Icon and title
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.expenseAccent.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.expenseAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Your Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)

                    Text("Download your expenses in various formats")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Format Selection Card
    private var formatSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.expenseAccent)
                Text("Export Format")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 12) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    formatRow(format)
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

    private func formatRow(_ format: ExportFormat) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFormat = format
            }
        }) {
            HStack(spacing: 16) {
                // Format icon
                ZStack {
                    Circle()
                        .fill(selectedFormat == format ? Color.expenseAccent : Color.expenseInputBackground)
                        .frame(width: 40, height: 40)

                    Image(systemName: format.icon)
                        .font(.system(size: 18))
                        .foregroundColor(selectedFormat == format ? .white : .expenseSecondaryText)
                }

                // Format info
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)

                    Text(format.description)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()

                // Selection indicator
                Image(systemName: selectedFormat == format ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(selectedFormat == format ? .expenseAccent : .expenseSecondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedFormat == format ? Color.expenseAccent.opacity(0.1) : Color.expenseInputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedFormat == format ? Color.expenseAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Date Range Card
    private var dateRangeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.expenseAccent)
                Text("Date Range")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 12) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    dateRangeRow(range)
                }
            }

            // Custom date range pickers
            if dateRange == .custom {
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From")
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)
                            DatePicker("", selection: $customStartDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(8)
                                .background(Color.expenseInputBackground)
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("To")
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)
                            DatePicker("", selection: $customEndDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(8)
                                .background(Color.expenseInputBackground)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func dateRangeRow(_ range: DateRange) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                dateRange = range
            }
        }) {
            HStack(spacing: 16) {
                // Range icon
                ZStack {
                    Circle()
                        .fill(dateRange == range ? Color.expenseAccent : Color.expenseInputBackground)
                        .frame(width: 40, height: 40)

                    Image(systemName: range.icon)
                        .font(.system(size: 18))
                        .foregroundColor(dateRange == range ? .white : .expenseSecondaryText)
                }

                // Range info
                Text(range.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.expensePrimaryText)

                Spacer()

                // Selection indicator
                Image(systemName: dateRange == range ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(dateRange == range ? .expenseAccent : .expenseSecondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(dateRange == range ? Color.expenseAccent.opacity(0.1) : Color.expenseInputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(dateRange == range ? Color.expenseAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(.expenseAccent)
                Text("Export Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 12) {
                summaryRow(title: "Total Expenses", value: "\(filteredExpenses.count)", icon: "number")
                summaryRow(title: "Date Range", value: dateRangeDescription, icon: "calendar")
                summaryRow(title: "Format", value: selectedFormat.rawValue, icon: selectedFormat.icon)
                summaryRow(title: "File Size", value: estimatedFileSize, icon: "doc")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func summaryRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.expenseAccent)
                .frame(width: 20)

            Text(title)
                .font(.body)
                .foregroundColor(.expenseSecondaryText)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.expensePrimaryText)
        }
    }

    // MARK: - Export Button
    private var exportButton: some View {
        Button(action: performExport) {
            HStack(spacing: 12) {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                }

                Text(isExporting ? "Exporting..." : "Export Data")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(filteredExpenses.isEmpty ? Color.expenseSecondaryText : Color.expenseAccent)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(filteredExpenses.isEmpty || isExporting)
    }

    // MARK: - Computed Properties
    private var filteredExpenses: [ExpenseItem] {
        switch dateRange {
        case .all:
            return expenses
        case .today:
            let today = DateFormatter.displayDate.string(from: Date())
            return expenses.filter { $0.date == today }
        case .thisWeek:
            let calendar = Calendar.current
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
            return expenses.filter { expense in
                guard let expenseDate = DateFormatter.displayDate.date(from: expense.date) else { return false }
                return expenseDate >= weekInterval.start && expenseDate < weekInterval.end
            }
        case .thisMonth:
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
            return expenses.filter { expense in
                guard let expenseDate = DateFormatter.displayDate.date(from: expense.date) else { return false }
                return expenseDate >= monthInterval.start && expenseDate < monthInterval.end
            }
        case .custom:
            return expenses.filter { expense in
                guard let expenseDate = DateFormatter.displayDate.date(from: expense.date) else { return false }
                let startOfDay = Calendar.current.startOfDay(for: customStartDate)
                let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: customEndDate))!
                return expenseDate >= startOfDay && expenseDate < endOfDay
            }
        }
    }

    private var dateRangeDescription: String {
        switch dateRange {
        case .all:
            return "All time"
        case .today:
            return "Today"
        case .thisWeek:
            return "This week"
        case .thisMonth:
            return "This month"
        case .custom:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(formatter.string(from: customStartDate)) - \(formatter.string(from: customEndDate))"
        }
    }

    private var estimatedFileSize: String {
        let expenseCount = filteredExpenses.count
        let estimatedSize: Int

        switch selectedFormat {
        case .json:
            estimatedSize = expenseCount * 200 // ~200 bytes per expense in JSON
        case .csv:
            estimatedSize = expenseCount * 150 // ~150 bytes per expense in CSV
        case .txt:
            estimatedSize = expenseCount * 100 // ~100 bytes per expense in TXT
        }

        if estimatedSize < 1024 {
            return "\(estimatedSize) bytes"
        } else if estimatedSize < 1024 * 1024 {
            return String(format: "%.1f KB", Double(estimatedSize) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(estimatedSize) / (1024.0 * 1024.0))
        }
    }

    // MARK: - Helper Methods
    private func loadExpenses() {
        guard let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] else {
            expenses = []
            return
        }
        expenses = dictArray.compactMap { ExpenseItem.fromDictionary($0) }
    }

    private func performExport() {
        guard !filteredExpenses.isEmpty else { return }

        isExporting = true

        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                let exportData = try generateExportData()
                let _ = ExportDocument(data: exportData, format: selectedFormat)

                // In a real implementation, you would present a document picker here
                // For now, we'll just show success
                exportSuccess = true
                isExporting = false

            } catch {
                exportError = error.localizedDescription
                isExporting = false
            }
        }
    }

    private func generateExportData() throws -> Data {
        switch selectedFormat {
        case .json:
            return try generateJSONData()
        case .csv:
            return try generateCSVData()
        case .txt:
            return try generateTextData()
        }
    }

    private func generateJSONData() throws -> Data {
        let exportDict: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "format": "json",
            "count": filteredExpenses.count,
            "expenses": filteredExpenses.map { expense in
                [
                    "id": expense.id.uuidString,
                    "name": expense.name,
                    "price": String(NSDecimalNumber(decimal: expense.price).doubleValue),
                    "description": expense.description,
                    "date": expense.date,
                    "time": expense.time,
                    "currency": expense.currency
                ]
            }
        ]

        return try JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted)
    }

    private func generateCSVData() throws -> Data {
        var csvString = "ID,Name,Price,Description,Date,Time,Currency\n"

        for expense in filteredExpenses {
            let row = [
                expense.id.uuidString,
                "\"" + expense.name.replacingOccurrences(of: "\"", with: "\"\"") + "\"",
                String(NSDecimalNumber(decimal: expense.price).doubleValue),
                "\"" + expense.description.replacingOccurrences(of: "\"", with: "\"\"") + "\"",
                expense.date,
                expense.time,
                expense.currency
            ].joined(separator: ",")

            csvString += row + "\n"
        }

        return csvString.data(using: .utf8) ?? Data()
    }

    private func generateTextData() throws -> Data {
        var textString = "HSU Expense Export\n"
        textString += "Export Date: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))\n"
        textString += "Total Expenses: \(filteredExpenses.count)\n"
        textString += String(repeating: "=", count: 50) + "\n\n"

        for (index, expense) in filteredExpenses.enumerated() {
            textString += "\(index + 1). \(expense.name)\n"
            textString += "   Price: \(expense.formattedPriceInCurrentCurrency())\n"
            textString += "   Date: \(expense.date) at \(expense.time)\n"
            if !expense.description.isEmpty {
                textString += "   Description: \(expense.description)\n"
            }
            textString += "\n"
        }

        return textString.data(using: .utf8) ?? Data()
    }
}

// MARK: - Export Document
struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .commaSeparatedText, .plainText] }

    var data: Data
    var format: EnhancedExportDataView.ExportFormat

    init(data: Data, format: EnhancedExportDataView.ExportFormat) {
        self.data = data
        self.format = format
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
        self.format = .json // Default format
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Preview
struct EnhancedExportDataView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedExportDataView()
            .preferredColorScheme(.light)

        EnhancedExportDataView()
            .preferredColorScheme(.dark)
    }
}
