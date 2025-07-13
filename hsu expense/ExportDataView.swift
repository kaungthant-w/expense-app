// ExportDataView.swift
import SwiftUI
import UniformTypeIdentifiers

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat = "JSON"
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isExporting = false
    @State private var showingSuccessAlert = false

    let exportFormats = ["JSON", "CSV"]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                headerSection

                // Export options
                exportOptionsSection

                // Format selection
                formatSelectionSection

                // Export button
                exportButtonSection

                // Test data button (for debugging)
                testDataButtonSection

                Spacer()
            }
            .padding(16)
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Export Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Export Completed", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your file has been exported successfully!\n\nTo save it:\n• Tap 'Save to Files' to save in Files app\n• Or choose another app to share\n• Files saved to Downloads or Documents can be accessed later")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url]) {
                    // Show success alert when share sheet is dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingSuccessAlert = true
                    }
                }
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

            Text("Export Data")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var exportOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Instructions")
                .font(.headline)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("• Select your preferred export format")
                Text("• JSON format preserves all data structure")
                Text("• CSV format is compatible with Excel")
                Text("• Files will be shared via iOS Share Sheet")
                Text("• You can save to Files app, email, or other apps")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private var formatSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Format")
                .font(.headline)
                .fontWeight(.bold)

            ForEach(exportFormats, id: \.self) { format in
                formatRow(format: format)
            }
        }
    }

    private func formatRow(format: String) -> some View {
        Button(action: {
            selectedFormat = format
        }) {
            HStack(spacing: 16) {
                Image(systemName: formatIcon(for: format))
                    .font(.title2)
                    .foregroundColor(formatColor(for: format))

                VStack(alignment: .leading, spacing: 4) {
                    Text(format)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(formatDescription(for: format))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if selectedFormat == format {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedFormat == format ? Color.green.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedFormat == format ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var exportButtonSection: some View {
        Button(action: {
            exportData()
        }) {
            HStack {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.headline)
                }

                Text(isExporting ? "Exporting..." : "Export Data")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isExporting ? Color.gray : Color.green)
            )
        }
        .disabled(isExporting)
    }

    private var testDataButtonSection: some View {
        Button(action: {
            addTestData()
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.headline)
                Text("Add Test Data")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
        }
    }

    // MARK: - Helper Functions

    private func formatIcon(for format: String) -> String {
        switch format {
        case "JSON": return "doc.text.fill"
        case "CSV": return "tablecells.fill"
        default: return "doc.fill"
        }
    }

    private func formatColor(for format: String) -> Color {
        switch format {
        case "JSON": return .blue
        case "CSV": return .green
        default: return .gray
        }
    }

    private func formatDescription(for format: String) -> String {
        switch format {
        case "JSON": return "Structured data format with full details"
        case "CSV": return "Spreadsheet-compatible format"
        default: return "Standard document format"
        }
    }

    private func exportData() {
        print("🚀 Export Data button clicked")
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("📊 Loading expenses from UserDefaults...")
                let expenses = loadExpensesFromUserDefaults()
                print("📊 Found \(expenses.count) expenses")

                let exportContent: String
                let fileName: String

                switch selectedFormat {
                case "JSON":
                    print("📄 Creating JSON export...")
                    exportContent = try createJSONExport(from: expenses)
                    fileName = "expense_export_\(dateString()).json"
                case "CSV":
                    print("📊 Creating CSV export...")
                    exportContent = createCSVExport(from: expenses)
                    fileName = "expense_export_\(dateString()).csv"
                default:
                    print("📄 Creating default JSON export...")
                    exportContent = try createJSONExport(from: expenses)
                    fileName = "expense_export_\(dateString()).json"
                }

                print("💾 Saving file: \(fileName)")
                let fileURL = try saveToFile(content: exportContent, fileName: fileName)
                print("✅ File saved successfully at: \(fileURL.path)")

                DispatchQueue.main.async {
                    print("📱 Showing share sheet...")
                    self.isExporting = false
                    self.exportedFileURL = fileURL
                    self.showingShareSheet = true
                }

            } catch {
                print("❌ Export failed: \(error)")
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.alertMessage = "Export failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }

    private func loadExpensesFromUserDefaults() -> [ExpenseItem] {
        print("🔍 Checking UserDefaults for expenses...")
        guard let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] else {
            print("⚠️ No expenses found in UserDefaults")
            return []
        }
        print("📋 Found \(dictArray.count) expense dictionaries in UserDefaults")
        let expenses = dictArray.compactMap { ExpenseItem.fromDictionary($0) }
        print("✅ Successfully converted \(expenses.count) expenses")
        return expenses
    }

    private func addTestData() {
        let testExpenses = [
            ExpenseItem(
                name: "Coffee Shop",
                price: Decimal(3.50),
                description: "Morning coffee",
                date: "2025-07-13",
                time: "08:30 AM",
                currency: "USD"
            ),
            ExpenseItem(
                name: "Lunch",
                price: Decimal(12.00),
                description: "Chicken sandwich and drink",
                date: "2025-07-13",
                time: "12:15 PM",
                currency: "USD"
            ),
            ExpenseItem(
                name: "Gas Station",
                price: Decimal(45.00),
                description: "Fill up car tank",
                date: "2025-07-13",
                time: "05:45 PM",
                currency: "USD"
            )
        ]

        // Load existing expenses
        var existingExpenses = loadExpensesFromUserDefaults()

        // Add test expenses
        existingExpenses.append(contentsOf: testExpenses)

        // Save back to UserDefaults
        let dictArray = existingExpenses.map { $0.asDictionary }
        UserDefaults.standard.set(dictArray, forKey: ExpenseUserDefaultsKeys.expenses)

        print("✅ Added \(testExpenses.count) test expenses. Total: \(existingExpenses.count)")
    }

    private func createJSONExport(from expenses: [ExpenseItem]) throws -> String {
        let exportData: [String: Any] = [
            "app_name": "HSU Expense",
            "export_version": "1.0",
            "export_date": ISO8601DateFormatter().string(from: Date()),
            "expenses": expenses.map { expense in
                [
                    "id": expense.id.uuidString,
                    "name": expense.name,
                    "price": NSDecimalNumber(decimal: expense.price).doubleValue,
                    "description": expense.description,
                    "date": expense.date,
                    "time": expense.time,
                    "currency": expense.currency
                ]
            },
            "total_expenses": expenses.count
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }

    private func createCSVExport(from expenses: [ExpenseItem]) -> String {
        var csv = "ID,Name,Price,Description,Date,Time,Currency\n"

        for expense in expenses {
            let row = [
                expense.id.uuidString,
                expense.name,
                String(NSDecimalNumber(decimal: expense.price).doubleValue),
                expense.description,
                expense.date,
                expense.time,
                expense.currency
            ].map { field in
                // Escape quotes and wrap in quotes if contains comma
                let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
                return field.contains(",") || field.contains("\"") || field.contains("\n") ? "\"\(escaped)\"" : escaped
            }.joined(separator: ",")

            csv += row + "\n"
        }

        return csv
    }

    private func saveToFile(content: String, fileName: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
}

// MARK: - ShareSheet for iOS

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let completion: (() -> Void)?

    init(activityItems: [Any], completion: (() -> Void)? = nil) {
        self.activityItems = activityItems
        self.completion = completion
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("📤 Creating UIActivityViewController with \(activityItems.count) items")
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // Set completion handler
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            print("📤 Share sheet completed - Activity: \(activityType?.rawValue ?? "none"), Completed: \(completed)")
            if let error = error {
                print("❌ Share sheet error: \(error)")
            }
            completion?()
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
