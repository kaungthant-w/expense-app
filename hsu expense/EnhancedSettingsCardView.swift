//
//  EnhancedSettingsCardView.swift
//  HSU Expense
//
//  Created by GitHub Copilot on 7/12/25.
//

import SwiftUI

struct EnhancedSettingsCardView: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String?
    let showChevron: Bool
    let accentColor: Color
    let action: () -> Void

    init(
        icon: String,
        title: String,
        subtitle: String,
        value: String? = nil,
        showChevron: Bool = true,
        accentColor: Color = .expenseAccent,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.showChevron = showChevron
        self.accentColor = accentColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon container with accent color
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(accentColor)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Value and chevron
                HStack(spacing: 8) {
                    if let value = value {
                        Text(value)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.expenseSecondaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.expenseInputBackground)
                            )
                    }

                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.expenseSecondaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.expenseCardBackground)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.expenseCardBorder.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(SettingsCardButtonStyle())
    }
}

// MARK: - Settings Card Button Style
struct SettingsCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Settings Section View
struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expenseSecondaryText)
                    .textCase(.uppercase)

                Spacer()
            }
            .padding(.horizontal, 4)

            // Section content
            VStack(spacing: 12) {
                content
            }
        }
    }
}

// MARK: - Toggle Settings Card
struct ToggleSettingsCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    @Binding var isOn: Bool

    init(
        icon: String,
        title: String,
        subtitle: String,
        accentColor: Color = .expenseAccent,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self._isOn = isOn
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(accentColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.expensePrimaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.expenseCardBorder.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Info Settings Card
struct InfoSettingsCard: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color

    init(
        icon: String,
        title: String,
        value: String,
        accentColor: Color = .expenseSecondaryText
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.accentColor = accentColor
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(accentColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.expensePrimaryText)

                Text(value)
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.expenseCardBorder.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Action Settings Card (for destructive actions)
struct ActionSettingsCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionType: ActionType
    let action: () -> Void

    enum ActionType {
        case normal
        case destructive
        case warning

        var color: Color {
            switch self {
            case .normal: return .expenseAccent
            case .destructive: return .expenseError
            case .warning: return .orange
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(actionType.color.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(actionType.color)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(actionType == .destructive ? .expenseError : .expensePrimaryText)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.expenseSecondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.expenseCardBackground)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(actionType == .destructive ? Color.expenseError.opacity(0.3) : Color.expenseCardBorder.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(SettingsCardButtonStyle())
    }
}

// MARK: - Enhanced Settings Page
struct EnhancedSettingsPage: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyManager = CurrencyManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingExportView = false
    @State private var showingImportView = false
    @State private var showingLanguageSettings = false
    @State private var showingThemeSettings = false
    @State private var showingCurrencySettings = false
    @State private var showingAboutView = false
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false
    @State private var autoBackup = true
    @State private var showingResetAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerView

                    // Quick Stats
                    quickStatsView

                    // Preferences Section
                    SettingsSectionView(title: "Preferences") {
                        EnhancedSettingsCardView(
                            icon: "globe",
                            title: "Language & Region",
                            subtitle: "App language and regional settings",
                            value: currentLanguage,
                            accentColor: .expenseEdit
                        ) {
                            showingLanguageSettings = true
                        }

                        EnhancedSettingsCardView(
                            icon: "paintbrush.fill",
                            title: "Theme & Appearance",
                            subtitle: "Dark mode, colors, and visual style",
                            value: currentTheme,
                            accentColor: .expenseAccent
                        ) {
                            showingThemeSettings = true
                        }

                        EnhancedSettingsCardView(
                            icon: "dollarsign.circle.fill",
                            title: "Currency Settings",
                            subtitle: "Default currency and exchange rates",
                            value: currencyManager.currentCurrency.code,
                            accentColor: .expenseGreen
                        ) {
                            showingCurrencySettings = true
                        }
                    }

                    // Security Section
                    SettingsSectionView(title: "Security & Privacy") {
                        ToggleSettingsCard(
                            icon: "bell.fill",
                            title: "Notifications",
                            subtitle: "Expense reminders and updates",
                            accentColor: .expenseEdit,
                            isOn: $notificationsEnabled
                        )

                        ToggleSettingsCard(
                            icon: "faceid",
                            title: "Biometric Authentication",
                            subtitle: "Use Face ID or Touch ID to secure app",
                            accentColor: .expenseAccent,
                            isOn: $biometricEnabled
                        )

                        ToggleSettingsCard(
                            icon: "icloud.fill",
                            title: "Auto Backup",
                            subtitle: "Automatically backup data to iCloud",
                            accentColor: .expenseGreen,
                            isOn: $autoBackup
                        )
                    }

                    // Data Management Section
                    SettingsSectionView(title: "Data Management") {
                        EnhancedSettingsCardView(
                            icon: "square.and.arrow.up",
                            title: "Export Data",
                            subtitle: "Download your expenses in various formats",
                            accentColor: .expenseGreen
                        ) {
                            showingExportView = true
                        }

                        EnhancedSettingsCardView(
                            icon: "square.and.arrow.down",
                            title: "Import Data",
                            subtitle: "Upload expenses from files",
                            accentColor: .expenseEdit
                        ) {
                            showingImportView = true
                        }

                        ActionSettingsCard(
                            icon: "trash.fill",
                            title: "Reset All Data",
                            subtitle: "Permanently delete all expenses",
                            actionType: .destructive
                        ) {
                            showingResetAlert = true
                        }
                    }

                    // App Information Section
                    SettingsSectionView(title: "App Information") {
                        EnhancedSettingsCardView(
                            icon: "info.circle.fill",
                            title: "About HSU Expense",
                            subtitle: "Version, credits, and legal information",
                            accentColor: .expenseSecondaryText
                        ) {
                            showingAboutView = true
                        }

                        InfoSettingsCard(
                            icon: "hammer.fill",
                            title: "Version",
                            value: "1.0.0 (Build 1)",
                            accentColor: .expenseSecondaryText
                        )

                        InfoSettingsCard(
                            icon: "calendar",
                            title: "Last Updated",
                            value: "July 12, 2025",
                            accentColor: .expenseSecondaryText
                        )
                    }
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.expenseAccent)
                }
            }
        }
        .sheet(isPresented: $showingExportView) {
            ExportDataView()
        }
        .sheet(isPresented: $showingImportView) {
            EnhancedImportDataView()
        }
        .sheet(isPresented: $showingLanguageSettings) {
            EnhancedLanguageSettingsView()
        }
        .sheet(isPresented: $showingThemeSettings) {
            EnhancedThemeSettingsView()
        }
        .sheet(isPresented: $showingCurrencySettings) {
            CurrencySettingsView()
        }
        .sheet(isPresented: $showingAboutView) {
            AboutUsView()
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your expenses. This action cannot be undone.")
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // App icon and title
            HStack(spacing: 16) {
                // App icon or logo
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.expenseAccent)
                        .frame(width: 64, height: 64)

                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("HSU Expense")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)

                    Text("Manage your finances with ease")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        )
    }

    // MARK: - Quick Stats View
    private var quickStatsView: some View {
        HStack(spacing: 16) {
            quickStatCard(title: "Total Expenses", value: "\(totalExpenseCount)", icon: "number", color: .expenseAccent)
            quickStatCard(title: "This Month", value: currencyManager.formatDecimalAmount(monthlyTotal), icon: "calendar", color: .expenseGreen)
            quickStatCard(title: "Categories", value: "5", icon: "tag.fill", color: .expenseEdit)
        }
    }

    private func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Computed Properties
    private var currentLanguage: String {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            return savedLanguage.uppercased()
        }
        return "EN"
    }

    private var currentTheme: String {
        switch themeManager.currentTheme {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "Auto"
        }
    }

    private var totalExpenseCount: Int {
        guard let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] else {
            return 0
        }
        return dictArray.count
    }

    private var monthlyTotal: Decimal {
        guard let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] else {
            return 0
        }

        let expenses = dictArray.compactMap { ExpenseItem.fromDictionary($0) }
        let calendar = Calendar.current
        let now = Date()

        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else {
            return 0
        }

        return expenses.filter { expense in
            guard let expenseDate = DateFormatter.displayDate.date(from: expense.date) else { return false }
            return expenseDate >= monthInterval.start && expenseDate < monthInterval.end
        }.reduce(0) { total, expense in
            total + expense.convertedPrice(to: currencyManager.currentCurrency.code)
        }
    }

    // MARK: - Helper Methods
    private func resetAllData() {
        UserDefaults.standard.removeObject(forKey: ExpenseUserDefaultsKeys.expenses)
        NotificationCenter.default.post(name: NSNotification.Name("ReloadExpensesFromUserDefaults"), object: nil)
    }
}

// MARK: - Extension for ExpenseItem
extension ExpenseItem {
    func convertedPrice(to currencyCode: String) -> Decimal {
        if self.currency == currencyCode {
            return self.price
        }

        // Use CurrencyManager for conversion
        let doubleAmount = NSDecimalNumber(decimal: self.price).doubleValue
        let convertedDouble = CurrencyManager.shared.convertAmount(doubleAmount, from: self.currency, to: currencyCode)
        return Decimal(convertedDouble)
    }

    func formattedPriceInCurrentCurrency() -> String {
        let currencyManager = CurrencyManager.shared
        let convertedPrice = convertedPrice(to: currencyManager.currentCurrency.code)
        return currencyManager.formatDecimalAmount(convertedPrice)
    }
}

// MARK: - Preview
struct EnhancedSettingsCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                EnhancedSettingsCardView(
                    icon: "globe",
                    title: "Language & Region",
                    subtitle: "App language and regional settings",
                    value: "EN"
                ) { }

                ToggleSettingsCard(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Expense reminders and updates",
                    isOn: .constant(true)
                )

                ActionSettingsCard(
                    icon: "trash.fill",
                    title: "Reset All Data",
                    subtitle: "Permanently delete all expenses",
                    actionType: .destructive
                ) { }
            }
            .padding()
        }
        .background(Color.expenseBackground)
        .preferredColorScheme(.light)

        ScrollView {
            VStack(spacing: 16) {
                EnhancedSettingsCardView(
                    icon: "paintbrush.fill",
                    title: "Theme Settings",
                    subtitle: "Dark mode and appearance",
                    value: "Dark"
                ) { }

                InfoSettingsCard(
                    icon: "hammer.fill",
                    title: "Version",
                    value: "1.0.0 (Build 1)"
                )
            }
            .padding()
        }
        .background(Color.expenseBackground)
        .preferredColorScheme(.dark)
    }
}
