//
//  AboutUsView.swift
//  HSU Expense
//
//  Created by kmt on 7/12/25.
//

import SwiftUI

struct AboutUsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showContactAlert = false
    @State private var selectedContactType = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Back Button
                    headerSection
                    
                    // App Logo and Name
                    appInfoSection
                    
                    // About App Card
                    aboutAppCard
                    
                    // Features Card
                    featuresCard
                    
                    // Developer Info Card
                    developerInfoCard
                    
                    // Contact Us Card
                    contactUsCard
                    
                    // Version Info Card
                    versionInfoCard
                    
                    // Legal Card
                    legalCard
                    
                    Spacer(minLength: 20)
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showContactAlert) {
            Alert(
                title: Text("Contact Us"),
                message: Text("Opening \(selectedContactType)..."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.expensePrimaryText)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.expenseInputBackground)
                    )
            }
            
            // Title
            Text("About Us")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.expensePrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 14)
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            // App Icon
            SafeImage(
                imageName: "ItunesArtwork@2x",
                systemFallback: "dollarsign.circle.fill",
                width: 80,
                height: 80
            )
            .foregroundColor(.expenseAccent)
            
            // App Name
            Text("HSU Expense")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.expensePrimaryText)
            
            // App Tagline
            Text("📊 Track your expenses efficiently")
                .font(.subheadline)
                .foregroundColor(.expenseSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - About App Card
    private var aboutAppCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("About HSU Expense")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                Text("HSU Expense is a comprehensive expense tracking application designed to help you manage your finances efficiently. With support for multiple currencies, real-time exchange rates, and detailed analytics, it's your perfect companion for personal finance management.")
                    .font(.subheadline)
                    .foregroundColor(.expenseSecondaryText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Features Card
    private var featuresCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Key Features")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "💰", title: "Multi-Currency Support", description: "Support for USD, EUR, JPY, KRW, MMK, and more")
                    featureRow(icon: "📊", title: "Analytics Dashboard", description: "Detailed expense analysis and summary reports")
                    featureRow(icon: "💱", title: "Real-time Exchange", description: "Live currency exchange rates from Myanmar API")
                    featureRow(icon: "📱", title: "Modern UI", description: "Beautiful dark and light themes with glassmorphism design")
                    featureRow(icon: "💾", title: "Data Management", description: "Import/Export expenses with JSON format")
                    featureRow(icon: "🔄", title: "Auto-Sync", description: "Real-time updates across all currency conversions")
                }
            }
        }
    }
    
    // MARK: - Developer Info Card
    private var developerInfoCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Developer Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(alignment: .leading, spacing: 12) {
                    developerRow(label: "Developer", value: "Kyaw Myo Thant")
                    developerRow(label: "Company", value: "HSU Development")
                    developerRow(label: "Location", value: "Yangon, Myanmar")
                    developerRow(label: "Experience", value: "iOS & Flutter Developer")
                }
            }
        }
    }
    
    // MARK: - Contact Us Card
    private var contactUsCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Contact Us")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 12) {
                    contactButton(
                        icon: "envelope.fill",
                        title: "Email Support",
                        subtitle: "kyawmyothant.dev@gmail.com",
                        color: Color.expenseGreen
                    ) {
                        selectedContactType = "Email"
                        showContactAlert = true
                        // Open email client
                        if let url = URL(string: "mailto:kyawmyothant.dev@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    contactButton(
                        icon: "phone.fill",
                        title: "Phone Support",
                        subtitle: "+95 977 246 328",
                        color: Color.expenseEdit
                    ) {
                        selectedContactType = "Phone"
                        showContactAlert = true
                        // Open phone dialer
                        if let url = URL(string: "tel:+959123456789") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    contactButton(
                        icon: "message.fill",
                        title: "Feedback",
                        subtitle: "Send us your thoughts",
                        color: Color.expenseAccent
                    ) {
                        selectedContactType = "Feedback"
                        showContactAlert = true
                        // Open feedback form or email
                        if let url = URL(string: "mailto:kyawmyothant.dev@gmail.com?subject=HSU%20Expense%20Feedback") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Version Info Card
    private var versionInfoCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Version Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(alignment: .leading, spacing: 8) {
                    versionRow(label: "App Version", value: "1.0.0")
                    versionRow(label: "Build Number", value: "100")
                    versionRow(label: "iOS Version", value: UIDevice.current.systemVersion)
                    versionRow(label: "Device Model", value: UIDevice.current.modelName)
                    versionRow(label: "Last Updated", value: "July 2025")
                }
            }
        }
    }
    
    // MARK: - Legal Card
    private var legalCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Legal Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 12) {
                    legalButton(title: "Privacy Policy") {
                        // Open privacy policy
                        selectedContactType = "Privacy Policy"
                        showContactAlert = true
                    }
                    
                    legalButton(title: "Terms of Service") {
                        // Open terms of service
                        selectedContactType = "Terms of Service"
                        showContactAlert = true
                    }
                    
                    legalButton(title: "Open Source Licenses") {
                        // Open licenses
                        selectedContactType = "Open Source Licenses"
                        showContactAlert = true
                    }
                }
                
                Text("© 2025 Kyaw Myo Thant. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Helper Views
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.expensePrimaryText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
            }
            
            Spacer()
        }
    }
    
    private func developerRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.expenseSecondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.expensePrimaryText)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private func contactButton(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func versionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.expenseSecondaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.expensePrimaryText)
        }
    }
    
    private func legalButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.expensePrimaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Device Info Extension
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            let scalar = UnicodeScalar(UInt8(value))
            return identifier + String(scalar)
        }
        
        // Convert identifier to readable name
        switch identifier {
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        default: return identifier
        }
    }
}

// MARK: - Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
            .preferredColorScheme(.light)
        
        AboutUsView()
            .preferredColorScheme(.dark)
    }
}
