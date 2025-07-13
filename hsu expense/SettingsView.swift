// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLanguageSettings = false
    @State private var showThemeSettings = false
    @State private var showExportData = false
    @State private var showImportData = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background matching Android
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header with Back Button (matching Android layout)
                        headerSection

                        // Settings Cards (matching Android CardViews)
                        settingsCardsSection

                        Spacer(minLength: 20)
                    }
                    .padding(16) // matching Android padding="16dp"
                }
            }
            .navigationBarHidden(true)
        }
        // Navigation sheets
        .sheet(isPresented: $showLanguageSettings) {
            LanguageSettingsView()
        }
        .sheet(isPresented: $showThemeSettings) {
            ThemeSettingsView()
        }
        .sheet(isPresented: $showExportData) {
            ExportDataView()
        }
        .sheet(isPresented: $showImportData) {
            ImportDataView()
        }
    }

    // MARK: - Header Section (matching Android LinearLayout header)
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Back Button (matching Android ImageButton)
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 48, height: 48) // matching Android 48dp
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }

            // Title (matching Android TextView)
            Text("Settings")
                .font(.title) // matching Android textSize="24sp"
                .fontWeight(.bold) // matching Android textStyle="bold"
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 14) // matching Android layout_marginBottom="30dp"
    }

    // MARK: - Settings Cards Section
    private var settingsCardsSection: some View {
        VStack(spacing: 16) { // matching Android layout_marginBottom="16dp"
            // Language Settings Card
            SettingsCardView(
                title: "Language Settings",
                description: "Change app language and region",
                icon: "globe",
                iconColor: Color(hex: "#4CAF50")
            ) {
                showLanguageSettings = true
            }

            // Theme Settings Card
            SettingsCardView(
                title: "Theme Settings",
                description: "Switch between light and dark themes",
                icon: "paintbrush.fill",
                iconColor: Color(hex: "#9C27B0")
            ) {
                showThemeSettings = true
            }

            // Export Data Card
            SettingsCardView(
                title: "Export Data",
                description: "Save your expense data to external file",
                icon: "square.and.arrow.up.fill",
                iconColor: Color(hex: "#FF9800")
            ) {
                showExportData = true
            }

            // Import Data Card
            SettingsCardView(
                title: "Import Data",
                description: "Load expense data from external file",
                icon: "square.and.arrow.down.fill",
                iconColor: Color(hex: "#2196F3")
            ) {
                showImportData = true
            }
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
