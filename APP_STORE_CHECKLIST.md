# App Store Submission Checklist for HSU Expense

## 📱 App Information
- **App Name:** HSU Expense ✅
- **Bundle ID:** expense.hsu-expense ✅
- **Team ID:** WY3GFL6Y63 ✅
- **Version:** 1.0.0
- **Build Number:** 1
- **Category:** Finance
- **Age Rating:** 4+

## 🔐 Prerequisites
### Apple Developer Account
- [ ] Paid Apple Developer Program membership ($99/year)
- [ ] Team ID: WY3GFL6Y63 verified
- [ ] Valid distribution certificates

### App Store Connect Setup
- [ ] Create new app in App Store Connect
- [ ] Use Bundle ID: expense.hsu-expense
- [ ] Set app name: HSU Expense

## 📸 Required Assets

### App Icon
- [x] App Icon 1024x1024 (iTunes Artwork) - You have ItunesArtwork@2x.png
- [ ] Verify all icon sizes in Assets.xcassets

### Screenshots (Required for each device type)
- [ ] iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max) - 1290x2796 pixels
- [ ] iPhone 6.5" (iPhone 11 Pro Max, 12 Pro Max, 13 Pro Max) - 1284x2778 pixels
- [ ] iPhone 5.5" (iPhone 8 Plus) - 1242x2208 pixels

### Optional Assets
- [ ] App Preview videos (30 seconds max)
- [ ] iPad screenshots (if supporting iPad)

## 📝 App Store Metadata

### Basic Information
- [ ] **App Name:** HSU Expense
- [ ] **Subtitle:** Personal expense tracker
- [ ] **Promotional Text:** Track your expenses efficiently with multi-currency support

### Description (4000 characters max)
```
HSU Expense is a comprehensive expense tracking application designed to help you manage your finances efficiently. 

KEY FEATURES:
• Multi-Currency Support - USD, EUR, JPY, KRW, MMK, and more
• Real-time Exchange Rates - Live currency conversion using Myanmar API
• Beautiful Interface - Modern dark and light themes with glassmorphism design
• Data Management - Import/Export expenses with JSON format
• Analytics Dashboard - Detailed expense analysis and summary reports
• Auto-Sync - Real-time updates across all currency conversions

Perfect for personal finance management, travel expenses, and daily expense tracking.
```

### Keywords (100 characters max)
```
expense,tracker,budget,finance,money,currency,myanmar,exchange,rate,personal
```

### Support Information
- [ ] **App Support URL:** https://t.me/hsuexpense
- [ ] **Marketing URL:** (optional)
- [ ] **Privacy Policy URL:** (Required - create one)

### What's New (4000 characters max)
```
Welcome to HSU Expense v1.0!

• Track expenses with multi-currency support
• Real-time exchange rates
• Beautiful modern interface
• Import/Export functionality
• Comprehensive expense analytics
• Dark and light theme support
```

## 🔒 Privacy & Legal Requirements

### Privacy Policy (Required)
Create a privacy policy that covers:
- [ ] What data you collect
- [ ] How you use the data
- [ ] Data storage and security
- [ ] Third-party services (Myanmar Currency API)
- [ ] User rights

### App Review Information
- [ ] **Demo Account:** Not needed for this app
- [ ] **Notes for Reviewer:** 
```
HSU Expense is a personal finance app that helps users track expenses with multi-currency support. 
The app uses Myanmar Currency API for exchange rates. No user registration required.
All data is stored locally on the device.
```

## 🚀 Build Process

### For App Store Submission
```bash
# On Mac
chmod +x build_for_appstore.sh
./build_for_appstore.sh

# On Windows
.\build_for_appstore.ps1
```

### Upload Methods
1. **Xcode (Recommended):**
   - Open Xcode → Window → Organizer
   - Select your archive → Distribute App → App Store Connect

2. **Application Loader:**
   - Use the generated IPA file
   - Upload via Application Loader

3. **Transporter App:**
   - Download from Mac App Store
   - Drag IPA file to upload

## 📋 Pre-Submission Checklist

### Technical Requirements
- [ ] iOS 16.2+ minimum deployment target ✅
- [ ] arm64 architecture support ✅
- [ ] No crashes or bugs
- [ ] All features working properly
- [ ] Proper error handling

### App Store Guidelines Compliance
- [ ] No placeholder content
- [ ] All features functional
- [ ] Proper user interface
- [ ] No broken links
- [ ] Follows Human Interface Guidelines

### Testing
- [ ] Test on physical devices
- [ ] Test all currency conversions
- [ ] Test import/export functionality
- [ ] Test in both light and dark modes
- [ ] Test on different screen sizes

## 💰 Pricing
- [ ] **Price Tier:** Free or set price
- [ ] **Availability:** All countries or specific regions

## 📅 Release Planning
- [ ] **Manual Release:** Control when app goes live
- [ ] **Automatic Release:** Goes live immediately after approval
- [ ] **Scheduled Release:** Set specific date/time

## 🔄 After Submission
1. **Review Process:** 24-48 hours typically
2. **Possible Outcomes:**
   - ✅ Approved and live
   - ❌ Rejected with feedback
   - ⏳ In Review (waiting)

3. **If Rejected:**
   - Read rejection reasons carefully
   - Fix issues mentioned
   - Resubmit with resolution notes

## 📞 Support Contacts
- **Developer:** Kyaw Myo Thant
- **Email:** kyawmyothant.dev@gmail.com
- **Telegram:** t.me/hsuexpense

## 🎯 Success Metrics
After launch, monitor:
- Download numbers
- User reviews and ratings
- Crash reports
- User feedback
