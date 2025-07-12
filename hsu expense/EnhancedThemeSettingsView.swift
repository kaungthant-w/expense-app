//
//  EnhancedThemeSettingsView.swift
//  HSU Expense
//
//  Created by GitHub Copilot on 7/12/25.
//

import SwiftUI

struct EnhancedThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTheme: ThemeOption = .system
    @State private var showingCustomTheme = false
    @State private var accentColorSelection: AccentColor = .purple

    enum ThemeOption: String, CaseIterable, Identifiable {
        case light = "light"
        case dark = "dark"
        case system = "system"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }

        var description: String {
            switch self {
            case .light: return "Always use light appearance"
            case .dark: return "Always use dark appearance"
            case .system: return "Follow system settings"
            }
        }

        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "gear"
            }
        }

        var previewColors: (background: Color, surface: Color, text: Color) {
            switch self {
            case .light:
                return (
                    background: Color.white,
                    surface: Color.white,
                    text: Color.black
                )
            case .dark:
                return (
                    background: Color(red: 0.071, green: 0.071, blue: 0.071),
                    surface: Color(red: 0.176, green: 0.176, blue: 0.176),
                    text: Color.white
                )
            case .system:
                return (
                    background: Color(UIColor.systemBackground),
                    surface: Color(UIColor.secondarySystemBackground),
                    text: Color(UIColor.label)
                )
            }
        }
    }

    enum AccentColor: String, CaseIterable, Identifiable {
        case purple = "purple"
        case blue = "blue"
        case green = "green"
        case orange = "orange"
        case red = "red"
        case pink = "pink"
        case indigo = "indigo"
        case teal = "teal"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .purple: return "Purple"
            case .blue: return "Blue"
            case .green: return "Green"
            case .orange: return "Orange"
            case .red: return "Red"
            case .pink: return "Pink"
            case .indigo: return "Indigo"
            case .teal: return "Teal"
            }
        }

        var color: Color {
            switch self {
            case .purple: return Color(red: 0.384, green: 0.0, blue: 0.933)
            case .blue: return Color.blue
            case .green: return Color.green
            case .orange: return Color.orange
            case .red: return Color.red
            case .pink: return Color.pink
            case .indigo: return Color.indigo
            case .teal: return Color.teal
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard

                    // Theme Selection Card
                    themeSelectionCard

                    // Accent Color Card
                    accentColorCard

                    // Preview Card
                    previewCard

                    // Advanced Options Card
                    advancedOptionsCard
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Theme & Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.expenseAccent)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyThemeChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.expenseAccent)
                }
            }
            .sheet(isPresented: $showingCustomTheme) {
                CustomThemeView()
            }
        }
        .onAppear {
            loadCurrentTheme()
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

                    Image(systemName: "paintbrush.fill")
                        .font(.title2)
                        .foregroundColor(.expenseAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Theme Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)

                    Text("Customize your app's appearance")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()
            }

            // Theme stats
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(ThemeOption.allCases.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.expenseAccent)
                    Text("Themes")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                VStack(spacing: 4) {
                    Text("\(AccentColor.allCases.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.expenseGreen)
                    Text("Colors")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                VStack(spacing: 4) {
                    Text(colorScheme == .dark ? "Dark" : "Light")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.expenseEdit)
                    Text("Current")
                        .font(.caption)
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

    // MARK: - Theme Selection Card
    private var themeSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "circle.lefthalf.filled")
                    .foregroundColor(.expenseAccent)
                Text("Theme Mode")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 12) {
                ForEach(ThemeOption.allCases) { theme in
                    themeRow(theme)
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

    private func themeRow(_ theme: ThemeOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTheme = theme
            }
        }) {
            HStack(spacing: 16) {
                // Theme preview
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.previewColors.background)
                        .frame(width: 50, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.expenseCardBorder, lineWidth: 1)
                        )

                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.previewColors.surface)
                            .frame(width: 30, height: 8)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.previewColors.text)
                            .frame(width: 20, height: 4)
                    }
                }

                // Theme info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.expenseAccent)

                        Text(theme.displayName)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.expensePrimaryText)
                    }

                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()

                // Selection indicator
                Image(systemName: selectedTheme == theme ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(selectedTheme == theme ? .expenseAccent : .expenseSecondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedTheme == theme ? Color.expenseAccent.opacity(0.1) : Color.expenseInputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedTheme == theme ? Color.expenseAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Accent Color Card
    private var accentColorCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(.expenseAccent)
                Text("Accent Color")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(AccentColor.allCases) { color in
                    accentColorButton(color)
                }
            }

            // Custom color button
            Button(action: {
                showingCustomTheme = true
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.expenseInputBackground)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.expenseCardBorder, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            )

                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.expenseSecondaryText)
                    }

                    Text("Custom")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func accentColorButton(_ color: AccentColor) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                accentColorSelection = color
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.color)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(accentColorSelection == color ? Color.white : Color.clear, lineWidth: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(accentColorSelection == color ? color.color : Color.clear, lineWidth: 2)
                        )

                    if accentColorSelection == color {
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }

                Text(color.displayName)
                    .font(.caption)
                    .fontWeight(accentColorSelection == color ? .semibold : .regular)
                    .foregroundColor(accentColorSelection == color ? .expensePrimaryText : .expenseSecondaryText)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .foregroundColor(.expenseAccent)
                Text("Preview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            // Preview of the app with selected theme
            VStack(spacing: 16) {
                // Mock navigation bar
                HStack {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.white)

                    Spacer()

                    Text("HSU Expense")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(accentColorSelection.color)

                // Mock content
                VStack(spacing: 12) {
                    // Summary card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("📅 Today's Summary")
                                .font(.headline)
                                .foregroundColor(selectedTheme.previewColors.text)
                            Spacer()
                        }

                        HStack {
                            Text("Total Amount:")
                                .foregroundColor(selectedTheme.previewColors.text.opacity(0.7))
                            Spacer()
                            Text("$125.50")
                                .fontWeight(.bold)
                                .foregroundColor(accentColorSelection.color)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTheme.previewColors.surface)
                    )

                    // Mock expense item
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Coffee Shop")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTheme.previewColors.text)

                            Text("Today at 9:30 AM")
                                .font(.caption)
                                .foregroundColor(selectedTheme.previewColors.text.opacity(0.7))
                        }

                        Spacer()

                        Text("$5.50")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTheme.previewColors.surface)
                    )
                }
                .padding(16)
                .background(selectedTheme.previewColors.background)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.expenseCardBorder, lineWidth: 1)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Advanced Options Card
    private var advancedOptionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.expenseAccent)
                Text("Advanced Options")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 16) {
                // Auto dark mode toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto Dark Mode")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.expensePrimaryText)

                        Text("Automatically switch to dark mode at sunset")
                            .font(.caption)
                            .foregroundColor(.expenseSecondaryText)
                    }

                    Spacer()

                    Toggle("", isOn: .constant(false))
                        .toggleStyle(SwitchToggleStyle(tint: accentColorSelection.color))
                }

                Divider()
                    .background(Color.expenseCardBorder)

                // High contrast toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("High Contrast")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.expensePrimaryText)

                        Text("Increase contrast for better readability")
                            .font(.caption)
                            .foregroundColor(.expenseSecondaryText)
                    }

                    Spacer()

                    Toggle("", isOn: .constant(false))
                        .toggleStyle(SwitchToggleStyle(tint: accentColorSelection.color))
                }

                Divider()
                    .background(Color.expenseCardBorder)

                // Reduce motion toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reduce Motion")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.expensePrimaryText)

                        Text("Minimize animations and transitions")
                            .font(.caption)
                            .foregroundColor(.expenseSecondaryText)
                    }

                    Spacer()

                    Toggle("", isOn: .constant(false))
                        .toggleStyle(SwitchToggleStyle(tint: accentColorSelection.color))
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

    // MARK: - Helper Methods
    private func loadCurrentTheme() {
        // Load saved theme preferences
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ThemeOption(rawValue: savedTheme) {
            selectedTheme = theme
        }

        if let savedAccent = UserDefaults.standard.string(forKey: "accentColor"),
           let accent = AccentColor(rawValue: savedAccent) {
            accentColorSelection = accent
        }
    }

    private func applyThemeChanges() {
        // Save theme preferences
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        UserDefaults.standard.set(accentColorSelection.rawValue, forKey: "accentColor")

        // Apply theme changes
        themeManager.setTheme(selectedTheme)
        themeManager.setAccentColor(accentColorSelection.color)

        // Notify about theme change
        NotificationCenter.default.post(name: .themeChanged, object: nil)

        dismiss()
    }
}

// MARK: - Custom Theme View
struct CustomThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var customColor = Color.purple

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Choose Custom Color")
                    .font(.title2)
                    .fontWeight(.bold)

                ColorPicker("Custom Accent Color", selection: $customColor, supportsOpacity: false)
                    .labelsHidden()

                // Preview
                VStack(spacing: 16) {
                    Text("Preview")
                        .font(.headline)

                    HStack(spacing: 16) {
                        Button("Sample Button") {}
                            .foregroundColor(.white)
                            .padding()
                            .background(customColor)
                            .cornerRadius(10)

                        Image(systemName: "heart.fill")
                            .foregroundColor(customColor)
                            .font(.title)
                    }
                }

                Spacer()
            }
            .padding(32)
            .navigationTitle("Custom Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save custom color
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: EnhancedThemeSettingsView.ThemeOption = .system
    @Published var accentColor: Color = Color(red: 0.384, green: 0.0, blue: 0.933)

    private init() {
        loadSavedTheme()
    }

    func setTheme(_ theme: EnhancedThemeSettingsView.ThemeOption) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }

    func setAccentColor(_ color: Color) {
        accentColor = color
    }

    private func loadSavedTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = EnhancedThemeSettingsView.ThemeOption(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}

// MARK: - Preview
struct EnhancedThemeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedThemeSettingsView()
            .preferredColorScheme(.light)

        EnhancedThemeSettingsView()
            .preferredColorScheme(.dark)
    }
}
