// ImportDataView.swift
import SwiftUI

struct ImportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFilePicker = false
    @State private var showImportAlert = false
    
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
        .alert(isPresented: $showImportAlert) {
            Alert(
                title: Text("Import Successful"),
                message: Text("Your data has been imported successfully!"),
                dismissButton: .default(Text("OK"))
            )
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
            
            Text("• Select a JSON, CSV, or Excel file")
            Text("• Make sure the file follows the correct format")
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
}
