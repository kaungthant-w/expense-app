# prepare_for_sharing.ps1 - Prepare files for free iOS app sharing

Write-Host "📱 Preparing HSU Expense for Free Sharing" -ForegroundColor Green
Write-Host "=" * 45

# Create distribution directory
$DIST_DIR = "distribution"
if (Test-Path $DIST_DIR) { Remove-Item -Recurse -Force $DIST_DIR }
New-Item -ItemType Directory -Path $DIST_DIR

Write-Host "📁 Creating distribution folder..." -ForegroundColor Yellow

# Copy IPA file if it exists
if (Test-Path "build/ipa/HSU Expense.ipa") {
    Copy-Item "build/ipa/HSU Expense.ipa" "$DIST_DIR/HSU_Expense.ipa"
    Write-Host "✅ IPA file copied" -ForegroundColor Green
} else {
    Write-Host "⚠️  IPA file not found. Run build first!" -ForegroundColor Yellow
}

# Copy installation files
Copy-Item "install_page.html" "$DIST_DIR/"
Copy-Item "manifest.plist" "$DIST_DIR/"

# Copy app icon if available
if (Test-Path "hsu expense/Assets.xcassets/AppIcon.appiconset/ItunesArtwork@2x.png") {
    Copy-Item "hsu expense/Assets.xcassets/AppIcon.appiconset/ItunesArtwork@2x.png" "$DIST_DIR/app_icon.png"
    Write-Host "✅ App icon copied" -ForegroundColor Green
}

# Create README for hosting
$readmeContent = @"
# HSU Expense - Free iOS App Distribution

## 📁 Files in this directory:

- **HSU_Expense.ipa** - The iOS app file
- **install_page.html** - Installation webpage
- **manifest.plist** - iOS installation manifest
- **app_icon.png** - App icon for webpage

## 🌐 Free Hosting Options:

### 1. GitHub Pages (Recommended)
1. Create new GitHub repository
2. Upload all files to /docs folder
3. Enable GitHub Pages in repository settings
4. Your URL: https://yourusername.github.io/repository-name/install_page.html

### 2. Netlify Drop
1. Go to netlify.com
2. Drag this entire folder to Netlify Drop
3. Get instant URL

### 3. Vercel
1. Sign up at vercel.com
2. Deploy this folder
3. Get free URL

### 4. Firebase Hosting
1. Install Firebase CLI
2. Run: firebase init hosting
3. Deploy with: firebase deploy

## 📝 Before sharing:

1. **Update URLs in manifest.plist:**
   - Replace "https://yourserver.com" with your actual hosting URL
   
2. **Update URLs in install_page.html:**
   - Replace the itms-services URL with your manifest.plist URL

3. **Test installation:**
   - Open install_page.html on iPhone Safari
   - Verify installation works

## 📱 Sharing in Telegram:

```
🎉 HSU Expense App - Free Download!

💰 Personal expense tracker with:
• Multi-currency support (USD, MMK, EUR, JPY, etc.)
• Real-time exchange rates
• Beautiful modern interface
• Import/Export functionality

📲 Install: https://your-hosting-url.com/install_page.html
💬 Support: t.me/hsuexpense

⚠️ iOS 16.2+ required
```

## 🔧 Technical Notes:

- All URLs must use HTTPS for iOS installation
- Users need to trust developer certificate in Settings
- App works offline after installation
- No user registration required

For technical support: t.me/hsuexpense
"@

$readmeContent | Out-File -FilePath "$DIST_DIR/README.md" -Encoding UTF8

Write-Host ""
Write-Host "✅ Distribution package ready!" -ForegroundColor Green
Write-Host "📁 Files created in: $DIST_DIR" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Yellow
Write-Host "1. Choose a free hosting service (GitHub Pages recommended)"
Write-Host "2. Upload the files in '$DIST_DIR' folder"
Write-Host "3. Update URLs in manifest.plist and install_page.html"
Write-Host "4. Test installation on iPhone"
Write-Host "5. Share the link in Telegram!"
Write-Host ""
Write-Host "📋 Available files:" -ForegroundColor Cyan
Get-ChildItem $DIST_DIR | ForEach-Object { Write-Host "   • $($_.Name)" }

Write-Host ""
Write-Host "💡 Pro tip: Use GitHub Pages for completely free hosting!" -ForegroundColor Green
