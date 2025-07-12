//
//  AboutUsView.swift
//  hsu expense
//
//  Created on July 12, 2025.
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
            .background(Color(.systemBackground))
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
                    .foregroundColor(.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }
            
            // Title
            Text("About Us")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 14)
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            // App Icon
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 98/255, green: 0/255, blue: 238/255))
            
            // App Name
            Text("HSU Expense")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // App Tagline
            Text("📊 Track your expenses efficiently")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - About App Card
    private var aboutAppCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("About HSU Expense")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("HSU Expense is a comprehensive expense tracking application designed to help you manage your finances efficiently. With support for multiple currencies and detailed analytics, it's your perfect companion for personal finance management.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Features Card
    private var featuresCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Key Features")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "💰", title: "Multi-Currency Support", description: "Support for USD, EUR, MMK, and more")
                    featureRow(icon: "📊", title: "Analytics Dashboard", description: "Detailed expense analysis and reports")
                    featureRow(icon: "🖨️", title: "Bluetooth Printing", description: "Print reports via Bluetooth")
                    featureRow(icon: "💱", title: "Real-time Exchange", description: "Live currency exchange rates")
                    featureRow(icon: "🌙", title: "Dark Mode", description: "Beautiful dark and light themes")
                    featureRow(icon: "🌍", title: "Multi-Language", description: "English and Myanmar language support")
                }
            }
        }
    }
    
    // MARK: - Developer Info Card
    private var developerInfoCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Developer Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    developerRow(label: "Developer", value: "Kyaw Myo Thant")
                    developerRow(label: "Location", value: "Yangon, Myanmar")
                }
            }
        }
    }
    
    // MARK: - Contact Us Card
    private var contactUsCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Contact Us")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    contactButton(
                        icon: "envelope.fill",
                        title: "Email Support",
                        subtitle: "kyawmyothant.dev@gmail.com",
                        color: Color(hex: "#4CAF50")
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
                        subtitle: "+95 9 123 456 789",
                        color: Color(hex: "#2196F3")
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
                        color: Color(hex: "#9C27B0")
                    ) {
                        selectedContactType = "Feedback"
                        showContactAlert = true
                        // Open feedback form or email
                    }
                }
            }
        }
    }
    
    // MARK: - Version Info Card
    private var versionInfoCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Version Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    versionRow(label: "App Version", value: "1.0.0")
                    versionRow(label: "Build Number", value: "100")
                    versionRow(label: "iOS Version", value: UIDevice.current.systemVersion)
                    versionRow(label: "Device Model", value: UIDevice.current.deviceModelName)
                    versionRow(label: "Last Updated", value: "July 2025")
                }
            }
        }
    }
    
    // MARK: - Legal Card
    private var legalCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Legal Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    legalButton(title: "Privacy Policy") {
                        // Open privacy policy
                    }
                    
                    legalButton(title: "Terms of Service") {
                        // Open terms of service
                    }
                    
                    legalButton(title: "Open Source Licenses") {
                        // Open licenses
                    }
                }
                
                Text("© 2025 Kyaw Myo Thant. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func developerRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
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
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func versionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
    
    private func legalButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
