// LanguageSettingsView.swift
import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguage = "English"
    
    let languages = [
        ("English", "🇺🇸", "en"),
        ("မြန်မာ", "🇲🇲", "mm"),
        ("中文", "🇨🇳", "zh"),
        ("日本語", "🇯🇵", "ja")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                headerSection
                
                // Language options
                ForEach(languages, id: \.2) { language in
                    languageRow(
                        name: language.0,
                        flag: language.1,
                        code: language.2
                    )
                }
                
                Spacer()
            }
            .padding(16)
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
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
            
            Text("Language Settings")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func languageRow(name: String, flag: String, code: String) -> some View {
        Button(action: {
            selectedLanguage = name
        }) {
            HStack(spacing: 16) {
                Text(flag)
                    .font(.title)
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedLanguage == name {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
