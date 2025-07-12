// ThemeSettingsView.swift
import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTheme = "System"
    
    let themes = ["Light", "Dark", "System"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                headerSection
                
                // Theme options
                ForEach(themes, id: \.self) { theme in
                    themeRow(theme: theme)
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
            
            Text("Theme Settings")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func themeRow(theme: String) -> some View {
        Button(action: {
            selectedTheme = theme
        }) {
            HStack(spacing: 16) {
                Image(systemName: themeIcon(for: theme))
                    .font(.title2)
                    .foregroundColor(themeColor(for: theme))
                
                Text(theme)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedTheme == theme {
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
    
    private func themeIcon(for theme: String) -> String {
        switch theme {
        case "Light": return "sun.max.fill"
        case "Dark": return "moon.fill"
        case "System": return "gear"
        default: return "gear"
        }
    }
    
    private func themeColor(for theme: String) -> Color {
        switch theme {
        case "Light": return .orange
        case "Dark": return .purple
        case "System": return .blue
        default: return .gray
        }
    }
}
