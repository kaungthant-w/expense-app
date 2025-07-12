//
//  EnhancedLanguageSettingsView.swift
//  HSU Expense
//
//  Created by GitHub Copilot on 7/12/25.
//

import SwiftUI

struct EnhancedLanguageSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: AppLanguage = .english
    @State private var showingLanguageDetail = false
    @State private var selectedDetailLanguage: AppLanguage?

    enum AppLanguage: String, CaseIterable, Identifiable {
        case english = "en"
        case myanmar = "my"
        case chinese = "zh"
        case japanese = "ja"
        case korean = "ko"
        case thai = "th"
        case vietnamese = "vi"
        case spanish = "es"
        case french = "fr"
        case german = "de"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .english: return "English"
            case .myanmar: return "မြန်မာ"
            case .chinese: return "中文"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .thai: return "ไทย"
            case .vietnamese: return "Tiếng Việt"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            }
        }

        var nativeName: String {
            switch self {
            case .english: return "English"
            case .myanmar: return "မြန်မာ (Myanmar)"
            case .chinese: return "中文 (Chinese)"
            case .japanese: return "日本語 (Japanese)"
            case .korean: return "한국어 (Korean)"
            case .thai: return "ไทย (Thai)"
            case .vietnamese: return "Tiếng Việt (Vietnamese)"
            case .spanish: return "Español (Spanish)"
            case .french: return "Français (French)"
            case .german: return "Deutsch (German)"
            }
        }

        var flagEmoji: String {
            switch self {
            case .english: return "🇺🇸"
            case .myanmar: return "🇲🇲"
            case .chinese: return "🇨🇳"
            case .japanese: return "🇯🇵"
            case .korean: return "🇰🇷"
            case .thai: return "🇹🇭"
            case .vietnamese: return "🇻🇳"
            case .spanish: return "🇪🇸"
            case .french: return "🇫🇷"
            case .german: return "🇩🇪"
            }
        }

        var description: String {
            switch self {
            case .english: return "Primary language with full feature support"
            case .myanmar: return "Native language of Myanmar with Unicode support"
            case .chinese: return "Simplified Chinese with proper formatting"
            case .japanese: return "Japanese with yen currency formatting"
            case .korean: return "Korean with won currency formatting"
            case .thai: return "Thai with baht currency support"
            case .vietnamese: return "Vietnamese with dong currency support"
            case .spanish: return "Spanish with euro/peso currency support"
            case .french: return "French with euro currency support"
            case .german: return "German with euro currency support"
            }
        }

        var currencyCode: String {
            switch self {
            case .english: return "USD"
            case .myanmar: return "MMK"
            case .chinese: return "CNY"
            case .japanese: return "JPY"
            case .korean: return "KRW"
            case .thai: return "THB"
            case .vietnamese: return "VND"
            case .spanish: return "EUR"
            case .french: return "EUR"
            case .german: return "EUR"
            }
        }

        var isRightToLeft: Bool {
            return false // None of the current languages are RTL
        }

        var completionPercentage: Int {
            switch self {
            case .english: return 100
            case .myanmar: return 85
            case .chinese: return 90
            case .japanese: return 88
            case .korean: return 85
            case .thai: return 80
            case .vietnamese: return 82
            case .spanish: return 95
            case .french: return 92
            case .german: return 90
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard

                    // Current Language Card
                    currentLanguageCard

                    // Language List
                    languageListCard

                    // Language Information
                    languageInfoCard
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Language & Region")
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
                        applyLanguageChange()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.expenseAccent)
                }
            }
            .sheet(item: $selectedDetailLanguage) { language in
                LanguageDetailView(language: language)
            }
        }
        .onAppear {
            loadCurrentLanguage()
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

                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.expenseAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Language Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)

                    Text("Choose your preferred language and region")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()
            }

            // Quick stats
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(AppLanguage.allCases.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.expenseAccent)
                    Text("Languages")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                VStack(spacing: 4) {
                    Text("\(selectedLanguage.completionPercentage)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.expenseGreen)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                VStack(spacing: 4) {
                    Text(selectedLanguage.currencyCode)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.expenseEdit)
                    Text("Currency")
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

    // MARK: - Current Language Card
    private var currentLanguageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.expenseGreen)
                Text("Current Language")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            HStack(spacing: 16) {
                // Flag and language
                HStack(spacing: 12) {
                    Text(selectedLanguage.flagEmoji)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedLanguage.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.expensePrimaryText)

                        Text(selectedLanguage.nativeName)
                            .font(.subheadline)
                            .foregroundColor(.expenseSecondaryText)
                    }
                }

                Spacer()

                // Completion indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.expenseCardBorder, lineWidth: 3)
                            .frame(width: 40, height: 40)

                        Circle()
                            .trim(from: 0, to: CGFloat(selectedLanguage.completionPercentage) / 100.0)
                            .stroke(Color.expenseGreen, lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))

                        Text("\(selectedLanguage.completionPercentage)%")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.expenseGreen)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.expenseGreen.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.expenseGreen, lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Language List Card
    private var languageListCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet")
                    .foregroundColor(.expenseAccent)
                Text("Available Languages")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 1) {
                ForEach(AppLanguage.allCases) { language in
                    languageRow(language)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.expenseInputBackground)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedLanguage = language
            }
        }) {
            HStack(spacing: 16) {
                // Flag
                Text(language.flagEmoji)
                    .font(.system(size: 24))

                // Language info
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)

                    Text(language.nativeName)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }

                Spacer()

                // Completion percentage
                HStack(spacing: 8) {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.expenseCardBorder)
                            .frame(width: 40, height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(completionColor(language.completionPercentage))
                            .frame(width: CGFloat(language.completionPercentage) * 0.4, height: 4)
                    }

                    Text("\(language.completionPercentage)%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.expenseSecondaryText)
                        .frame(width: 30, alignment: .trailing)
                }

                // Selection indicator and details button
                HStack(spacing: 8) {
                    Button(action: {
                        selectedDetailLanguage = language
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.expenseAccent)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Image(systemName: selectedLanguage == language ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundColor(selectedLanguage == language ? .expenseAccent : .expenseSecondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                selectedLanguage == language ?
                Color.expenseAccent.opacity(0.1) :
                Color.clear
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Language Info Card
    private var languageInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.expenseAccent)
                Text("Language Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.expensePrimaryText)
            }

            VStack(spacing: 12) {
                infoRow(icon: "textformat", title: "Description", value: selectedLanguage.description)
                infoRow(icon: "dollarsign.circle", title: "Default Currency", value: selectedLanguage.currencyCode)
                infoRow(icon: "arrow.left.arrow.right", title: "Text Direction", value: selectedLanguage.isRightToLeft ? "Right to Left" : "Left to Right")
                infoRow(icon: "percent", title: "Translation Progress", value: "\(selectedLanguage.completionPercentage)% Complete")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
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
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Helper Methods
    private func completionColor(_ percentage: Int) -> Color {
        if percentage >= 90 {
            return .expenseGreen
        } else if percentage >= 70 {
            return .orange
        } else {
            return .expenseError
        }
    }

    private func loadCurrentLanguage() {
        // Load from UserDefaults or use system language
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            selectedLanguage = language
        } else {
            // Default to English or system language
            selectedLanguage = .english
        }
    }

    private func applyLanguageChange() {
        // Save language preference
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")

        // Update currency if needed
        if let currency = CurrencyManager.Currency.allCurrencies.first(where: { $0.code == selectedLanguage.currencyCode }) {
            CurrencyManager.shared.setCurrency(currency)
        }

        // Notify about language change
        NotificationCenter.default.post(name: .languageChanged, object: selectedLanguage)

        dismiss()
    }
}

// MARK: - Language Detail View
struct LanguageDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let language: EnhancedLanguageSettingsView.AppLanguage

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text(language.flagEmoji)
                            .font(.system(size: 80))

                        VStack(spacing: 8) {
                            Text(language.displayName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.expensePrimaryText)

                            Text(language.nativeName)
                                .font(.title3)
                                .foregroundColor(.expenseSecondaryText)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.expenseCardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )

                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Language Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.expensePrimaryText)

                        VStack(spacing: 12) {
                            detailRow(title: "Language Code", value: language.rawValue)
                            detailRow(title: "Default Currency", value: language.currencyCode)
                            detailRow(title: "Text Direction", value: language.isRightToLeft ? "Right to Left" : "Left to Right")
                            detailRow(title: "Translation Progress", value: "\(language.completionPercentage)%")

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.expenseSecondaryText)

                                Text(language.description)
                                    .font(.body)
                                    .foregroundColor(.expensePrimaryText)
                                    .fixedSize(horizontal: false, vertical: true)
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
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Language Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.expenseAccent)
                }
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
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
}

// MARK: - Notification Extension
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// MARK: - Preview
struct EnhancedLanguageSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedLanguageSettingsView()
            .preferredColorScheme(.light)

        EnhancedLanguageSettingsView()
            .preferredColorScheme(.dark)
    }
}
