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
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
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
                Text("• Your exported file will be saved and shared")
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
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let sampleData = loadSampleData()
                let exportContent: String
                let fileName: String

                switch selectedFormat {
                case "JSON":
                    exportContent = try createJSONExport(from: sampleData)
                    fileName = "expense_export_\(dateString()).json"
                case "CSV":
                    exportContent = createCSVExport(from: sampleData)
                    fileName = "expense_export_\(dateString()).csv"
                default:
                    exportContent = try createJSONExport(from: sampleData)
                    fileName = "expense_export_\(dateString()).json"
                }

                let fileURL = try saveToFile(content: exportContent, fileName: fileName)

                DispatchQueue.main.async {
                    self.isExporting = false
                    self.exportedFileURL = fileURL
                    self.showingShareSheet = true
                    self.alertMessage = "Export completed successfully!"
                }

            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.alertMessage = "Export failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }

    private func loadSampleData() -> [ExpenseItem] {
        // Load from sample_import_100.json
        guard let url = Bundle.main.url(forResource: "sample_import_100", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let expenses = json["expenses"] as? [[String: Any]] else {
            return []
        }

        return expenses.compactMap { expenseDict in
            guard let idString = expenseDict["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = expenseDict["name"] as? String,
                  let price = expenseDict["price"] as? Double,
                  let description = expenseDict["description"] as? String,
                  let date = expenseDict["date"] as? String,
                  let time = expenseDict["time"] as? String,
                  let currency = expenseDict["currency"] as? String else {
                return nil
            }

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
    }

    private func createJSONExport(from expenses: [ExpenseItem]) throws -> String {
        let exportData: [String: Any] = [
            "app_name": "HSU Expense",
            "export_version": "1.0",
            "export_date": ISO8601DateFormatter().string(from: Date()),
            "expenses": expenses.map { expense in
                [
                    "id": expense.id,
                    "name": expense.name,
                    "price": expense.price,
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

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
