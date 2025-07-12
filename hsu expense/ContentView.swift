// MARK: - UserDefaults Keys
private enum ExpenseUserDefaultsKeys {
    static let expenses = "hsu_expense_items"
}

// MARK: - ExpenseItem UserDefaults Conversion
extension ExpenseItem {
    // Convert ExpenseItem to dictionary for UserDefaults
    var asDictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "price": NSDecimalNumber(decimal: price).doubleValue,
            "description": description,
            "date": date,
            "time": time,
            "currency": currency
        ]
    }

    // Create ExpenseItem from dictionary
    static func fromDictionary(_ dict: [String: Any]) -> ExpenseItem? {
        // Accept id as String (UUID) or Int (legacy export)
        var id: UUID? = nil
        if let idString = dict["id"] as? String {
            id = UUID(uuidString: idString)
        } else if dict["id"] is Int {
            id = nil
        }
        guard let uuid = id,
              let name = dict["name"] as? String,
              let price = dict["price"] as? Double,
              let description = dict["description"] as? String,
              let currency = dict["currency"] as? String else {
            return nil
        }
        // Parse date (support multiple formats)
        var date: Date? = nil
        if let dateObj = dict["date"] as? Date {
            date = dateObj
        } else if let dateStr = dict["date"] as? String {
            let dateFormats = [
                "dd/MM/yyyy",
                "yyyy-MM-dd",
                "yyyy/MM/dd",
                "MM/dd/yyyy"
            ]
            for format in dateFormats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let d = formatter.date(from: dateStr) {
                    date = d
                    break
                }
            }
        }
        // Parse time (support multiple formats)
        var time: Date? = nil
        if let timeObj = dict["time"] as? Date {
            time = timeObj
        } else if let timeStr = dict["time"] as? String {
            let timeFormats = [
                "HH:mm",
                "HH:mm:ss",
                "h:mm a",
                "hh:mm a"
            ]
            for format in timeFormats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let t = formatter.date(from: timeStr) {
                    time = t
                    break
                }
            }
        }
        guard let dateVal = date, let timeVal = time else {
            return nil
        }
        return ExpenseItem(id: uuid, name: name, price: Decimal(price), description: description, date: dateVal, time: timeVal, currency: currency)
    }
}
//
//  ContentView.swift
//  HSU Expense
//
//  Created by kmt on 7/9/25.
//

import SwiftUI
import CoreData
import Combine

// MARK: - Expense Data Model (SwiftUI Compatible)
struct ExpenseItem: Identifiable {
    let id: UUID
    var name: String
    var price: Decimal
    var description: String
    var date: Date
    var time: Date
    var currency: String
    
    init(id: UUID = UUID(), name: String = "", price: Decimal = 0, description: String = "", date: Date = Date(), time: Date = Date(), currency: String = "USD") {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.date = date
        self.time = time
        self.currency = currency
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        if currency == "JPY" || currency == "KRW" {
            // Japanese Yen and Korean Won don't use decimal places
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
        } else {
            // All other currencies show 2 decimal places
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
        }
        
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

// MARK: - Design System Colors (matching Android design)
extension Color {
    // Light/Dark theme background colors
    static let expenseBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1.0) : // #FF121212
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFFFF
    })
    
    static let expenseCardBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 0.176, green: 0.176, blue: 0.176, alpha: 1.0) : // #FF2D2D2D
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFFFF
    })
    
    static let expensePrimaryText = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : // #FFFFFFFF
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // #FF000000
    })
    
    static let expenseSecondaryText = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) : // #FFCCCCCC
            UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1.0) // #FF555555
    })
    
    static let expenseInputBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.0) : // #FF383838
            UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1.0) // #FFF8F8F8
    })
    
    // Primary accent color (purple from Android App Bar)
    static let expenseAccent = Color(red: 0.384, green: 0.0, blue: 0.933) // #FF6200EE
    static let expenseError = Color(red: 0.957, green: 0.263, blue: 0.212) // #FFF44336
    static let expenseEdit = Color(red: 0.129, green: 0.588, blue: 0.953) // #FF2196F3
    static let expenseGreen = Color(red: 0.298, green: 0.686, blue: 0.314) // #4CAF50
    
    // Surface and border colors
    static let expenseSurface = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1.0) : // #FF1E1E1E
            UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1.0) // #FFF5F5F5
    })
    
    static let expenseCardBorder = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? 
            UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 1.0) : // #FF404040
            UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0) // #FFE0E0E0
    })
}

// MARK: - Safe Image View (handles asset loading with fallbacks)
struct SafeImage: View {
    let imageName: String
    let systemFallback: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Group {
            // Try to load ItunesArtwork@2x.png first, then imageName, then system fallback
            if let uiImage = UIImage(named: "ItunesArtwork@2x") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: systemFallback)
                    .font(.system(size: min(width, height) * 0.6))
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Custom Logo View (fallback when no custom image is available)
struct CustomLogoView: View {
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 70, height: 70)
            
            // Custom logo design
            VStack(spacing: 2) {
                Text("HSU")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var expenses: [ExpenseItem] = []
    @State private var showingAddExpense = false
    @State private var selectedExpense: ExpenseItem?
    @State private var totalExpenses: Decimal = 0
    @State private var selectedTab = 0 {
        didSet {
            // Ensure selectedTab is always in valid range
            if selectedTab < 0 || selectedTab > 3 {
                selectedTab = 0
            }
        }
    }
    @State private var showingNavigationDrawer = false
    @State private var showSettingsPage = false
    @State private var showCurrencySettings = false
    @State private var showSummaryView = false
    @State private var showAboutUs = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content (equivalent to CoordinatorLayout)
                VStack(spacing: 0) {
                    // Main Content with proper layout behavior
                    VStack(spacing: 10) {
                        // Today's Summary Card (matching Android CardView)
                        todaySummaryCardView
                        
                        // Tab Layout equivalent
                        tabLayoutView
                        
                        // ViewPager equivalent with TabView
                        viewPagerView
                    }
                    .padding(.horizontal, 10)
                    .background(Color.expenseBackground)
                }
                .navigationTitle("HSU Expense")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingNavigationDrawer = true }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .toolbarBackground(Color.expenseAccent, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar) // Ensures white title text
                
                VStack {
                    // Main content area
                    Spacer()
                    
                    // Settings button in navigation or toolbar
                    HStack {
                        Spacer()
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingNavigationDrawer) {
            NavigationDrawerView()
        }
        .sheet(isPresented: $showSettingsPage) {
            SettingsPage()
        }
        .sheet(isPresented: $showCurrencySettings) {
            CurrencySettingsView()
        }
        .sheet(isPresented: $showSummaryView) {
            InlineSummaryView()
        }
        .sheet(isPresented: $showAboutUs) {
            AboutUsView()
        }
        .sheet(isPresented: $showingAddExpense) {
            ExpenseDetailView(expense: nil) { newExpense in
                addExpense(newExpense)
            }
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseDetailView(expense: expense) { updatedExpense in
                updateExpense(updatedExpense)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            loadExpensesFromUserDefaults()
            calculateTotal()
            // debugTabData() // Debug information - can be removed later
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowSettingsPage"), object: nil, queue: .main) { _ in
                showSettingsPage = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowCurrencySettings"), object: nil, queue: .main) { _ in
                showCurrencySettings = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowSummary"), object: nil, queue: .main) { _ in
                showSummaryView = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowAboutUs"), object: nil, queue: .main) { _ in
                showAboutUs = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ReloadExpensesFromUserDefaults"), object: nil, queue: .main) { _ in
                loadExpensesFromUserDefaults()
                calculateTotal()
            }
            // Listen for currency changes to refresh UI
            NotificationCenter.default.addObserver(forName: .currencyChanged, object: nil, queue: .main) { _ in
                calculateTotal()
            }
        }
    }
    
    // MARK: - Today's Summary Card View (matching Android CardView)
    private var todaySummaryCardView: some View {
        VStack(spacing: 0) {
            // Card container with elevation and corner radius
            VStack(alignment: .leading, spacing: 14) {
                    // Title
                    HStack {
                        Text("📅 Today's Summary")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.expensePrimaryText)
                        
                        Spacer()
                    }
                .padding(.bottom, 2)
                
                // Total Number row
                HStack {
                    Text("Total Number:")
                        .font(.system(size: 14))
                        .foregroundColor(.expenseSecondaryText)
                    Spacer()
                    Text("\(todayExpensesCount)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.expensePrimaryText)
                }
                .padding(.bottom, 8)
                
                // Total Amount row
                HStack {
                    Text("Total Amount:")
                        .font(.system(size: 14))
                        .foregroundColor(.expenseSecondaryText)
                    Spacer()
                    Text(currencyManager.currentCurrency.format(todayTotalAmountInCurrentCurrency))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.expensePrimaryText)
                }
            }
            .padding(14)
            .background(Color.expenseCardBackground)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Tab Layout View (equivalent to TabLayout)
    private var tabLayoutView: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 8) {
                        // Multi-line tab title
                        if index == 1 { // THIS WEEK
                            VStack(spacing: 2) {
                                Text("THIS")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(selectedTab == index ? Color.expensePrimaryText : Color.expenseSecondaryText)
                                Text("WEEK")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(selectedTab == index ? Color.expensePrimaryText : Color.expenseSecondaryText)
                            }
                        } else if index == 2 { // THIS MONTH
                            VStack(spacing: 2) {
                                Text("THIS")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(selectedTab == index ? Color.expensePrimaryText : Color.expenseSecondaryText)
                                Text("MONTH")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(selectedTab == index ? Color.expensePrimaryText : Color.expenseSecondaryText)
                            }
                        } else {
                            Text(tabTitle(for: index))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedTab == index ? Color.expensePrimaryText : Color.expenseSecondaryText)
                        }
                        
                        // Tab indicator
                        Rectangle()
                            .fill(selectedTab == index ? Color.expenseAccent : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.clear)
    }
    
    // MARK: - ViewPager equivalent with TabView
    private var viewPagerView: some View {
        TabView(selection: $selectedTab) {
            // Today's Expenses Tab
            todayExpenseListView
                .tag(0)
            
            // This Week's Expenses Tab
            thisWeekExpenseListView
                .tag(1)
            
            // This Month's Expenses Tab
            thisMonthExpenseListView
                .tag(2)
            
            // All Expenses Tab (3 years of data)
            allExpenseListView
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    

    // MARK: - Helper Properties
    private var todayExpensesCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return expenses.filter { expense in
            expense.date >= today && expense.date < tomorrow
        }.count
    }
    
    private var todayTotalAmount: Decimal {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return expenses.filter { expense in
            expense.date >= today && expense.date < tomorrow
        }.reduce(0) { $0 + $1.price }
    }
    
    private var todayTotalAmountInCurrentCurrency: Decimal {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return expenses.filter { expense in
            expense.date >= today && expense.date < tomorrow
        }.reduce(0) { total, expense in
            total + expense.convertedPrice(to: currencyManager.currentCurrency.code)
        }
    }
    
    private var todayExpenses: [ExpenseItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return expenses.filter { expense in
            expense.date >= today && expense.date < tomorrow
        }.sorted { $0.date > $1.date }
    }
    
    // Three years of data for ALL tab
    private var allExpenses: [ExpenseItem] {
        let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
        return expenses.filter { expense in
            expense.date >= threeYearsAgo
        }.sorted { $0.date > $1.date }
    }
    
    // This week's expenses
    private var thisWeekExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the start of this week (Sunday or Monday depending on locale)
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return []
        }
        
        let startOfWeek = weekInterval.start
        let endOfWeek = weekInterval.end
        
        return expenses.filter { expense in
            expense.date >= startOfWeek && expense.date < endOfWeek
        }.sorted { $0.date > $1.date }
    }
    
    // This month's expenses
    private var thisMonthExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the start of this month
        guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
            return []
        }
        
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        return expenses.filter { expense in
            expense.date >= startOfMonth && expense.date < endOfMonth
        }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Tab Views
    private var allExpenseListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if allExpenses.isEmpty {
                    EmptyStateView {
                        showingAddExpense = true
                    }
                } else {
                    ForEach(allExpenses) { expense in
                        ExpenseRowView(expense: expense) {
                            selectedExpense = expense
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private var todayExpenseListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if todayExpenses.isEmpty {
                    EmptyStateView {
                        showingAddExpense = true
                    }
                } else {
                    ForEach(todayExpenses) { expense in
                        ExpenseRowView(expense: expense) {
                            selectedExpense = expense
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private var thisWeekExpenseListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if thisWeekExpenses.isEmpty {
                    EmptyStateView {
                        showingAddExpense = true
                    }
                } else {
                    ForEach(thisWeekExpenses) { expense in
                        ExpenseRowView(expense: expense) {
                            selectedExpense = expense
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private var thisMonthExpenseListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if thisMonthExpenses.isEmpty {
                    EmptyStateView {
                        showingAddExpense = true
                    }
                } else {
                    ForEach(thisMonthExpenses) { expense in
                        ExpenseRowView(expense: expense) {
                            selectedExpense = expense
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private var expenseCategories: [(category: String, count: Int, totalAmount: Decimal, iconName: String)] {
        let grouped = Dictionary(grouping: expenses) { expense in
            categoryName(for: expense.name)
        }
        
        return grouped.map { (category, expenses) in
            let count = expenses.count
            let totalAmount = expenses.reduce(0) { $0 + $1.price }
            let iconName = categoryIconName(for: expenses.first?.name ?? "")
            return (category: category, count: count, totalAmount: totalAmount, iconName: iconName)
        }.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private func categoryName(for expenseName: String) -> String {
        let lowercaseName = expenseName.lowercased()
        if lowercaseName.contains("food") || lowercaseName.contains("restaurant") || lowercaseName.contains("grocery") || lowercaseName.contains("lunch") || lowercaseName.contains("coffee") {
            return "Food & Dining"
        } else if lowercaseName.contains("gas") || lowercaseName.contains("fuel") || lowercaseName.contains("car") || lowercaseName.contains("transport") || lowercaseName.contains("taxi") || lowercaseName.contains("uber") {
            return "Transportation"
        } else if lowercaseName.contains("shop") || lowercaseName.contains("store") || lowercaseName.contains("market") || lowercaseName.contains("mall") {
            return "Shopping"
        } else if lowercaseName.contains("movie") || lowercaseName.contains("entertainment") {
            return "Entertainment"
        } else {
            return "General"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "TODAY"
        case 1: return "THIS WEEK"
        case 2: return "THIS MONTH"
        case 3: return "ALL"
        default:
            assertionFailure("Invalid tab index: \(index)")
            return ""
        }
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
    
    private func calculateTotal() {
        totalExpenses = expenses.reduce(0) { $0 + $1.price }
    }

    // MARK: - UserDefaults CRUD
    private func saveExpensesToUserDefaults() {
        let dictArray = expenses.map { $0.asDictionary }
        UserDefaults.standard.set(dictArray, forKey: ExpenseUserDefaultsKeys.expenses)
    }

    private func loadExpensesFromUserDefaults() {
        guard let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] else {
            expenses = []
            return
        }
        expenses = dictArray.compactMap { ExpenseItem.fromDictionary($0) }
    }

    private func addExpense(_ expense: ExpenseItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            expenses.append(expense)
            saveExpensesToUserDefaults()
            calculateTotal()
        }
    }

    private func updateExpense(_ updatedExpense: ExpenseItem) {
        // If the update is a delete signal, remove the expense
        if updatedExpense.name == "__DELETE__" {
            deleteExpense(updatedExpense)
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                expenses[index] = updatedExpense
                saveExpensesToUserDefaults()
                calculateTotal()
            }
        }
    }

    private func deleteExpense(_ expense: ExpenseItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let oldCount = expenses.count
            expenses.removeAll { $0.id == expense.id }
            saveExpensesToUserDefaults()
            calculateTotal()
            // Double check: If deletion failed, reload from UserDefaults
            if expenses.count == oldCount {
                loadExpensesFromUserDefaults()
            }
        }
    }

    // For development: Remove all data from UserDefaults
    private func clearAllExpensesFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: ExpenseUserDefaultsKeys.expenses)
        expenses = []
        calculateTotal()
    }
    
    private func categoryIconName(for name: String) -> String {
        // Always return ExpenseIcon for all categories
        return "ExpenseIcon"
    }
    
    // MARK: - Debug Helper (for testing - can be removed later)
    private func debugTabData() {
        print("=== TAB DATA DEBUG ===")
        print("Tab Order: TODAY(0), THIS WEEK(1), THIS MONTH(2), ALL(3)")
        print("Today expenses: \(todayExpenses.count)")
        print("This week expenses: \(thisWeekExpenses.count)")
        print("This month expenses: \(thisMonthExpenses.count)")
        print("All expenses (3 years): \(allExpenses.count)")
        print("Total expenses: \(expenses.count)")
        
        let calendar = Calendar.current
        let today = Date()
        
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            print("Week range: \(weekInterval.start) to \(weekInterval.end)")
        }
        
        if let monthInterval = calendar.dateInterval(of: .month, for: today) {
            print("Month range: \(monthInterval.start) to \(monthInterval.end)")
        }
        
        print("Today's date: \(today)")
        
        // Print each expense with its date for debugging
        print("\n--- Expense Details ---")
        for (index, expense) in expenses.enumerated() {
            print("\(index + 1). \(expense.name) - \(expense.formattedDate)")
        }
        print("====================")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.light)
        
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.dark)
    }
}

struct NavigationDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDrawerView()
            .preferredColorScheme(.light)
        
        NavigationDrawerView()
            .preferredColorScheme(.dark)
    }
}

struct CategoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRowView(
            category: "Food & Dining",
            count: 5,
            totalAmount: 125.50,
            iconName: "ExpenseIcon"
        )
        .padding()
        .preferredColorScheme(.light)
        
        CategoryRowView(
            category: "Transportation",
            count: 3,
            totalAmount: 85.75,
            iconName: "ExpenseIcon"
        )
        .padding()
        .preferredColorScheme(.dark)
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView(expense: nil) { _ in }
            .preferredColorScheme(.light)
        
        ExpenseDetailView(expense: ExpenseItem(
            name: "Sample Expense",
            price: 25.50,
            description: "This is a sample expense for preview"
        )) { _ in }
            .preferredColorScheme(.dark)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView { }
            .preferredColorScheme(.light)
        
        EmptyStateView { }
            .preferredColorScheme(.dark)
    }
}

// MARK: - Supporting Views

// MARK: - Stat Item View
struct StatItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.expenseAccent)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.expenseSecondaryText)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.expensePrimaryText)
        }
    }
}

// MARK: - Expense Row View
struct ExpenseRowView: View {
    let expense: ExpenseItem
    let onTap: () -> Void
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Expense Name
                    Text(expense.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.expensePrimaryText)
                        .lineLimit(1)
                    Spacer()
                    
                    // Price display
                    Text(expense.formattedPriceInCurrentCurrency())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.expenseGreen)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Date and Time Row
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.expenseSecondaryText)
                        Text(expense.formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.expenseSecondaryText)
                    }
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.expenseSecondaryText)
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.expenseSecondaryText)
                        Text(expense.formattedTime)
                            .font(.system(size: 12))
                            .foregroundColor(.expenseSecondaryText)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.expenseCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.expenseCardBorder, lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIconName(for name: String) -> String {
        // Always return ExpenseIcon for all categories
        return "ExpenseIcon"
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let onAddExpense: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // Use a system image as the primary icon for better reliability
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.expenseSecondaryText)
                    .opacity(0.6)
                
                VStack(spacing: 8) {
                    Text("No Expenses Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.expensePrimaryText)
                    
                    Text("Start tracking your expenses by adding your first entry")
                        .font(.body)
                        .foregroundColor(.expenseSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Button(action: onAddExpense) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    
                    Text("Add Your First Expense")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.expenseAccent)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Expense Detail View (SwiftUI Version)
struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var expense: ExpenseItem
    @State private var isNewExpense: Bool
    @State private var selectedCurrency: CurrencyManager.Currency
    @State private var originalCurrency: String
    @State private var originalPrice: Decimal
    let onSave: (ExpenseItem) -> Void
    
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var showingCurrencyPicker = false
    
    init(expense: ExpenseItem?, onSave: @escaping (ExpenseItem) -> Void) {
        if let expense = expense {
            self._expense = State(initialValue: expense)
            self._isNewExpense = State(initialValue: false)
            self._originalCurrency = State(initialValue: expense.currency)
            self._originalPrice = State(initialValue: expense.price)
        } else {
            let newExpense = ExpenseItem(currency: CurrencyManager.shared.currentCurrency.code)
            self._expense = State(initialValue: newExpense)
            self._isNewExpense = State(initialValue: true)
            self._originalCurrency = State(initialValue: CurrencyManager.shared.currentCurrency.code)
            self._originalPrice = State(initialValue: 0)
        }
        // Always use current currency regardless of existing expense currency
        self._selectedCurrency = State(initialValue: CurrencyManager.shared.currentCurrency)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Main Content Card
                    VStack(spacing: 20) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                    .foregroundColor(.expenseAccent)
                                Text("Name")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                            
                            TextField("Enter expense name", text: $expense.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(12)
                                .background(Color.expenseInputBackground)
                                .cornerRadius(10)
                        }
                        
                        // Price Field with Currency Selection
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.expenseAccent)
                                Text("Price")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                            
                            HStack(spacing: 12) {
                                // Price input
                                TextField("0.00", value: Binding(
                                    get: { NSDecimalNumber(decimal: expense.price).doubleValue },
                                    set: { expense.price = Decimal($0) }
                                ), format: .number.precision(.fractionLength(2)))
                                .font(.body)
                                .fontWeight(.medium)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(Color.expenseInputBackground)
                                .cornerRadius(10)
                                
                                // Currency selector (temporarily disabled)
                                /*
                                Button(action: { showingCurrencyPicker = true }) {
                                    HStack(spacing: 6) {
                                        Text(selectedCurrency.flag)
                                            .font(.body)
                                        Text(selectedCurrency.code)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                    }
                                    .foregroundColor(.expenseAccent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background(Color.expenseInputBackground)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                */
                            }
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "note.text")
                                    .font(.caption)
                                    .foregroundColor(.expenseAccent)
                                Text("Description")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                            
                            TextField("Enter description (optional)", text: $expense.description, axis: .vertical)
                                .font(.body)
                                .padding(12)
                                .background(Color.expenseInputBackground)
                                .cornerRadius(10)
                                .lineLimit(3...6)
                        }
                        
                        // Date & Time Fields
                        HStack(spacing: 12) {
                            // Date Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.expenseAccent)
                                    Text("Date")
                                        .font(.caption)
                                        .foregroundColor(.expenseSecondaryText)
                                }
                                
                                Button(action: { showingDatePicker = true }) {
                                    Text(expense.formattedDate)
                                        .font(.body)
                                        .foregroundColor(.expensePrimaryText)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.expenseInputBackground)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Time Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.expenseAccent)
                                    Text("Time")
                                        .font(.caption)
                                        .foregroundColor(.expenseSecondaryText)
                                }
                                
                                Button(action: { showingTimePicker = true }) {
                                    Text(expense.formattedTime)
                                        .font(.body)
                                        .foregroundColor(.expensePrimaryText)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.expenseInputBackground)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.expenseCardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Save Button
                        Button(action: saveExpense) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                
                                Text(isNewExpense ? "Save" : "Update")
                                    .font(.body)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.expenseAccent)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(expense.name.isEmpty)
                        
                        // Delete Button (only for existing expenses)
                        if !isNewExpense {
                            Button(action: {
                                // Signal delete by special name, will be handled in updateExpense
                                onSave(ExpenseItem(id: expense.id, name: "__DELETE__", price: 0, description: "", date: expense.date, time: expense.time, currency: expense.currency))
                                dismiss()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                        .font(.body)
                                    
                                    Text("Delete")
                                        .font(.body)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.expenseError)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle(isNewExpense ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(date: $expense.date, title: "Select Date")
            }
            .sheet(isPresented: $showingTimePicker) {
                TimePickerView(time: $expense.time, title: "Select Time")
            }
            // Currency picker temporarily disabled until project files are synced
            // .sheet(isPresented: $showingCurrencyPicker) {
            //     CurrencyPickerView(selectedCurrency: $selectedCurrency) { currency in
            //         selectedCurrency = currency
            //         expense.currency = currency.code
            //         showingCurrencyPicker = false
            //     }
            // }
            .onAppear {
                // Update selected currency to current currency manager currency
                selectedCurrency = currencyManager.currentCurrency
                expense.currency = currencyManager.currentCurrency.code
                
                // Convert price if editing existing expense and currency is different
                if !isNewExpense && originalCurrency != currencyManager.currentCurrency.code {
                    expense.price = currencyManager.convertAmount(originalPrice, from: originalCurrency, to: currencyManager.currentCurrency.code)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .currencyChanged)) { _ in
                // Update when currency changes
                let oldCurrency = selectedCurrency.code
                selectedCurrency = currencyManager.currentCurrency
                expense.currency = currencyManager.currentCurrency.code
                
                // Convert price when currency changes
                if oldCurrency != currencyManager.currentCurrency.code {
                    expense.price = currencyManager.convertAmount(expense.price, from: oldCurrency, to: currencyManager.currentCurrency.code)
                }
            }
        }
    }
    
    private func saveExpense() {
        // Set the expense currency to the current selected currency
        expense.currency = selectedCurrency.code
        onSave(expense)
        dismiss()
    }
}

// MARK: - Date Picker View
struct DatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date
    let title: String
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Time Picker View
struct TimePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var time: Date
    let title: String
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Currency Picker View (Temporarily commented out until CurrencyManager is added to project)
/*
struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: CurrencyManager.Currency
    let onSelect: (CurrencyManager.Currency) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(CurrencyManager.Currency.allCurrencies, id: \.code) { currency in
                    Button(action: {
                        onSelect(currency)
                    }) {
                        HStack(spacing: 12) {
                            Text(currency.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.expensePrimaryText)
                                
                                Text("\(currency.symbol) \(currency.code)")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                            
                            Spacer()
                            
                            if currency.code == selectedCurrency.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundColor(.expenseGreen)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
*/

struct NavigationDrawerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Enhanced Header Section (matching Android drawable design)
                VStack(alignment: .leading, spacing: 12) {
                    // Logo and title section
                    VStack(alignment: .leading, spacing: 16) {
                        // App icon image
                        SafeImage(
                            imageName: "ItunesArtwork@2x",
                            systemFallback: "app.badge",
                            width: 60,
                            height: 60
                        )
                        
                        // Description text
                        Text("Track your expenses efficiently")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    ZStack {
                        // Main gradient background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 98/255, green: 0/255, blue: 238/255), // #6200EE
                                Color(red: 55/255, green: 0/255, blue: 179/255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Subtle pattern overlay
                        GeometryReader { geometry in
                            Path { path in
                                // Add subtle geometric patterns
                                let width = geometry.size.width
                                let height = geometry.size.height
                                
                                // Add some circles for visual interest
                                path.addEllipse(in: CGRect(x: width * 0.8, y: -20, width: 60, height: 60))
                                path.addEllipse(in: CGRect(x: -20, y: height * 0.6, width: 40, height: 40))
                            }
                            .fill(Color.white.opacity(0.05))
                        }
                    }
                )
                
                // Menu Items Container
                ScrollView {
                    VStack(spacing: 0) {
                        // Main Group
                        NavigationMenuSection(title: "MAIN") {
                            NavigationMenuItem(icon: "", title: "Home", emoji: "🏠") {
                                dismiss()
                            }
                            NavigationMenuItem(icon: "", title: "All Expense", emoji: "📋") {
                                dismiss()
                            }
                            NavigationMenuItem(icon: "", title: "History", emoji: "🗃️") {
                                dismiss()
                            }
                            NavigationMenuItem(icon: "", title: "Summary", emoji: "📊") {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowSummary"), object: nil)
                                }
                            }
                            NavigationMenuItem(icon: "", title: "Currency", emoji: "💱") {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowCurrencySettings"), object: nil)
                                }
                            }
                            NavigationMenuItem(icon: "", title: "Printer", emoji: "🖨️") {
                                dismiss()
                            }
                        }
                        
                        // Group Separator
                        Divider()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                        
                        // Settings Group
                        NavigationMenuSection(title: "SETTINGS") {
                            NavigationMenuItem(icon: "", title: "Settings", emoji: "⚙️") {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowSettingsPage"), object: nil)
                                }
                            }
                            NavigationMenuItem(icon: "", title: "Feedback", emoji: "💬") {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    // Open feedback email
                                    if let url = URL(string: "mailto:kyawmyothant.dev@gmail.com?subject=HSU%20Expense%20Feedback") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                            NavigationMenuItem(icon: "", title: "About Us", emoji: "ℹ️") {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowAboutUs"), object: nil)
                                }
                            }
                        }
                    }
                }
                .background(Color.expenseCardBackground)
                
                Spacer()
            }
            .background(Color.expenseCardBackground)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Navigation Menu Section
struct NavigationMenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            if !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.expenseSecondaryText)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
            
            // Section Content
            content
        }
    }
}

// MARK: - Navigation Menu Item
struct NavigationMenuItem: View {
    let icon: String
    let title: String
    let emoji: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Only show emoji
                Text(emoji)
                    .font(.title3)
                    .frame(width: 32, alignment: .leading)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.expensePrimaryText)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Color.clear
                    .contentShape(Rectangle())
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Color.expenseAccent
                .opacity(0.05)
                .opacity(0) // Remove this line to show selection highlight
        )
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: String
    let count: Int
    let totalAmount: Decimal
    let iconName: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(Color.expenseAccent.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                SafeImage(
                    imageName: iconName,
                    systemFallback: "tag.circle",
                    width: 24,
                    height: 24
                )
                .foregroundColor(.expenseAccent)
            }
            
            // Category Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.expensePrimaryText)
                
                Text("\(count) items")
                    .font(.caption)
                    .foregroundColor(.expenseSecondaryText)
            }
            
            Spacer()
            
            // Total Amount (show as $2.00 style)
            Text("$" + String(format: "%.2f", NSDecimalNumber(decimal: totalAmount).doubleValue))
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.expensePrimaryText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Settings Page
import UniformTypeIdentifiers
import Foundation

struct SettingsPage: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var importError: String? = nil
    @State private var importSuccess: Bool = false
    @State private var importFileURL: URL? = nil
    @State private var expenses: [ExpenseItem] = []
    @State private var totalExpenses: Int = 0
    @State private var isImporting = false
    @State private var isExporting = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                Button(action: { showExporter = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Expenses")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.expenseAccent)
                    .cornerRadius(12)
                }
                Button(action: { showImporter = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import Expenses")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.expenseEdit)
                    .cornerRadius(12)
                }
                if let error = importError {
                    Text(error)
                        .foregroundColor(.expenseError)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                if importSuccess {
                    Text("Import successful!")
                        .foregroundColor(.green)
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .fileExporter(isPresented: $showExporter, document: ExportDocument(expenses: loadExpensesForExport()), contentType: .json, defaultFilename: exportFileName()) { result in
                if case .failure(let error) = result {
                    importError = "Export failed: \(error.localizedDescription)"
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        importFileURL = url
                        importExpenses(from: url)
                    }
                case .failure(let error):
                    importError = "Import failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadExpensesForExport() -> [ExpenseItem] {
        let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] ?? []
        return dictArray.compactMap { ExpenseItem.fromDictionary($0) }
    }

    private func exportFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "hsu_expense_export_\(formatter.string(from: Date())).json"
    }

    private func importExpenses(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let data = try Data(contentsOf: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                importError = "Invalid file format."
                return
            }
            // Support both stringified and array for "expenses" field
            var importedExpensesArray: [[String: Any]] = []
            if let expensesString = json["expenses"] as? String {
                if let expensesData = expensesString.data(using: .utf8),
                   let arr = try? JSONSerialization.jsonObject(with: expensesData) as? [[String: Any]] {
                    importedExpensesArray = arr
                }
            } else if let arr = json["expenses"] as? [[String: Any]] {
                importedExpensesArray = arr
            }
            if importedExpensesArray.isEmpty {
                importError = "No expenses found in import file."
                return
            }
            // Overwrite: Only use imported expenses
            let importedExpenses = importedExpensesArray.compactMap { ExpenseItem.fromDictionary($0) }
            if importedExpenses.isEmpty {
                importError = "No valid expenses to import."
                importSuccess = false
                return
            }
            let importedArray = importedExpenses.map { $0.asDictionary }
            UserDefaults.standard.set(importedArray, forKey: ExpenseUserDefaultsKeys.expenses)
            // Notify ContentView to reload data
            NotificationCenter.default.post(name: NSNotification.Name("ReloadExpensesFromUserDefaults"), object: nil)
            importSuccess = true
            importError = nil
        } catch {
            importError = "Import failed: \(error.localizedDescription)"
        }
    }
}

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var expenses: [ExpenseItem]

    init(expenses: [ExpenseItem]) {
        self.expenses = expenses
    }

    init(configuration: ReadConfiguration) throws {
        guard let fileURL = configuration.file.regularFileContents else {
            self.expenses = []
            return
        }
        let data = fileURL
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let expensesString = (json?["expenses"] as? String) ?? "[]"
        let expensesData = expensesString.data(using: String.Encoding.utf8) ?? Data()
        let expensesArray = try JSONSerialization.jsonObject(with: expensesData) as? [[String: Any]] ?? []
        self.expenses = expensesArray.compactMap { ExpenseItem.fromDictionary($0) }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let exportDict: [String: Any] = [
            "app_name": "HSU Expense",
            "export_version": "1.0",
            "export_date": exportDateString(),
            "expenses": exportExpensesJSONString(),
            "total_expenses": expenses.count
        ]
        let data = try JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted)
        return FileWrapper(regularFileWithContents: data)
    }

    private func exportDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }

    private func exportExpensesJSONString() -> String {
        let arr = expenses.map { exp -> [String: Any] in
            var dict = exp.asDictionary
            dict["isDeleted"] = false
            dict["deletedAt"] = ""
            dict["date"] = dateString(exp.date)
            dict["time"] = timeString(exp.time)
            dict["id"] = exp.id.uuidString // Always export as UUID string
            return dict
        }
        if let data = try? JSONSerialization.data(withJSONObject: arr, options: []),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "[]"
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Comprehensive Currency Management System
class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    @Published var currentCurrency: Currency = .usd
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoadingRates = false
    @Published var lastUpdateTime: Date?
    @Published var apiError: String?
    
    private init() {
        loadSavedCurrency()
        loadSavedRates()
    }
    
    // MARK: - Currency Definition
    struct Currency: Identifiable, Equatable {
        let id = UUID()
        let code: String
        let name: String
        let symbol: String
        let flag: String
        
        static let usd = Currency(code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸")
        static let mmk = Currency(code: "MMK", name: "Myanmar Kyat", symbol: "MMK", flag: "🇲🇲")
        static let eur = Currency(code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺")
        static let jpy = Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flag: "🇯🇵")
        static let gbp = Currency(code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧")
        static let cny = Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flag: "🇨🇳")
        static let krw = Currency(code: "KRW", name: "Korean Won", symbol: "₩", flag: "🇰🇷")
        static let thb = Currency(code: "THB", name: "Thai Baht", symbol: "฿", flag: "🇹🇭")
        static let sgd = Currency(code: "SGD", name: "Singapore Dollar", symbol: "S$", flag: "🇸🇬")
        static let inr = Currency(code: "INR", name: "Indian Rupee", symbol: "₹", flag: "🇮🇳")
        
        static let allCurrencies: [Currency] = [.usd, .mmk, .eur, .jpy, .gbp, .cny, .krw, .thb, .sgd, .inr]
        
        func format(_ amount: Decimal) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = self.code
            formatter.currencySymbol = self.symbol
            
            // All currencies show 2 decimal places
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            
            return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(symbol)0.00"
        }
    }
    
    // MARK: - Public Methods
    func setCurrency(_ currency: Currency) {
        currentCurrency = currency
        saveCurrency()
        NotificationCenter.default.post(name: .currencyChanged, object: nil)
        
        // Auto-fetch rates when currency changes
        if exchangeRates.isEmpty || shouldRefreshRates() {
            fetchExchangeRates()
        }
    }
    
    func convertAmount(_ amount: Decimal, from: String, to: String) -> Decimal {
        guard from != to else { return amount }
        
        // Convert to USD first (base currency)
        let usdAmount: Decimal
        if from == "USD" {
            usdAmount = amount
        } else if let fromRate = exchangeRates[from] {
            usdAmount = amount / Decimal(fromRate)
        } else {
            return amount // Fallback if no rate available
        }
        
        // Convert from USD to target currency
        if to == "USD" {
            return usdAmount
        } else if let toRate = exchangeRates[to] {
            return usdAmount * Decimal(toRate)
        } else {
            return amount // Fallback if no rate available
        }
    }
    
    func fetchExchangeRates() {
        guard !isLoadingRates else { return }
        
        isLoadingRates = true
        apiError = nil
        
        guard let url = URL(string: "https://myanmar-currency-api.github.io/api/latest.json") else {
            handleFetchError("Invalid API URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingRates = false
                
                if let error = error {
                    self?.handleFetchError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.handleFetchError("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]] {
                        
                        var newRates: [String: Double] = [:]
                        
                        // Parse Myanmar API format
                        for currencyData in dataArray {
                            if let currency = currencyData["currency"] as? String,
                               let sellString = currencyData["sell"] as? String,
                               let sellRate = Double(sellString.replacingOccurrences(of: ".", with: "")) {
                                // Convert sell rate to proper format
                                // Myanmar API gives rates in MMK per 1 foreign currency
                                // We need rates as foreign currency per 1 USD
                                if currency == "USD" {
                                    // For USD to MMK rate
                                    newRates["MMK"] = sellRate
                                } else if currency == "JPN" {
                                    // Handle JPN -> JPY mapping
                                    newRates["JPY"] = 1.0 / (sellRate / 100.0) // Convert to proper JPY rate
                                } else {
                                    // For other currencies, convert to USD rate
                                    if sellRate > 0 {
                                        newRates[currency] = 1.0 / (sellRate / newRates["MMK", default: 4400.0])
                                    }
                                }
                            }
                        }
                        
                        // Add some missing currencies with fallback rates
                        if newRates["EUR"] == nil { newRates["EUR"] = 0.85 }
                        if newRates["GBP"] == nil { newRates["GBP"] = 0.72 }
                        if newRates["KRW"] == nil { newRates["KRW"] = 1180.0 }
                        if newRates["INR"] == nil { newRates["INR"] = 74.0 }
                        
                        self?.exchangeRates = newRates
                        self?.lastUpdateTime = Date()
                        self?.saveRates()
                        self?.apiError = nil
                    } else {
                        self?.handleFetchError("Invalid response format")
                    }
                } catch {
                    self?.handleFetchError("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // MARK: - Private Methods
    private func handleFetchError(_ message: String) {
        apiError = message
        if exchangeRates.isEmpty {
            // Load fallback rates if no rates available
            loadFallbackRates()
        }
    }
    
    private func loadFallbackRates() {
        exchangeRates = [
            "MMK": 2100.0,
            "EUR": 0.85,
            "JPY": 110.0,
            "GBP": 0.72,
            "CNY": 6.45,
            "KRW": 1180.0,
            "THB": 33.0,
            "SGD": 1.35,
            "INR": 74.0
        ]
    }
    
    private func shouldRefreshRates() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return Date().timeIntervalSince(lastUpdate) > 3600 // Refresh every hour
    }
    
    private func saveCurrency() {
        UserDefaults.standard.set(currentCurrency.code, forKey: "SelectedCurrency")
    }
    
    private func loadSavedCurrency() {
        if let savedCode = UserDefaults.standard.string(forKey: "SelectedCurrency"),
           let currency = Currency.allCurrencies.first(where: { $0.code == savedCode }) {
            currentCurrency = currency
        }
    }
    
    private func saveRates() {
        if let data = try? JSONSerialization.data(withJSONObject: exchangeRates) {
            UserDefaults.standard.set(data, forKey: "ExchangeRates")
            UserDefaults.standard.set(Date(), forKey: "RatesUpdateTime")
        }
    }
    
    private func loadSavedRates() {
        if let data = UserDefaults.standard.data(forKey: "ExchangeRates"),
           let rates = try? JSONSerialization.jsonObject(with: data) as? [String: Double] {
            exchangeRates = rates
            lastUpdateTime = UserDefaults.standard.object(forKey: "RatesUpdateTime") as? Date
       
        } else {
            loadFallbackRates()
        }
    }
}

// MARK: - Notification Extension
extension NSNotification.Name {
    static let currencyChanged = NSNotification.Name("CurrencyChanged")
}

// MARK: - ExpenseItem Currency Extensions
extension ExpenseItem {
    func convertedPrice(to targetCurrency: String) -> Decimal {
        return CurrencyManager.shared.convertAmount(price, from: currency, to: targetCurrency)
    }
    
    func formattedPriceInCurrentCurrency() -> String {
        let convertedPrice = convertedPrice(to: CurrencyManager.shared.currentCurrency.code)
        return CurrencyManager.shared.currentCurrency.format(convertedPrice)
    }
    
    func formattedPriceInOriginalCurrency() -> String {
        if let originalCurrency = CurrencyManager.Currency.allCurrencies.first(where: { $0.code == currency }) {
            return originalCurrency.format(price)
        }
        return CurrencyManager.Currency.usd.format(price)
    }
}

// MARK: - Inline Summary View (to avoid separate file import issues)
struct InlineSummaryView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var summaryData = InlineSummaryData()
    @State private var showingRateDetails = false
    @Environment(\.resentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header with Back Button
                    headerSection
                    
                    // Overall Summary Card
                    overallSummaryCard
                    
                    // Today's Summary Card
                    todaySummaryCard
                    
                    // Weekly Summary Card
                    weeklySummaryCard
                    
                    // Monthly Summary Card
                    monthlySummaryCard
                    
                    // Extremes Card
                    extremesCard
                    
                    Spacer(minLength: 20)
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationBarHidden(true)
        }
        .onAppear {
            loadSummaryData()
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
            Text("Summary")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.expensePrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 14)
    }
    
    // MARK: - Overall Summary Card
    private var overallSummaryCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Overall Statistics")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 8) {
                    summaryRow(
                        label: "Total Expenses",
                        value: "\(summaryData.totalExpenseCount)",
                        valueColor: .expensePrimaryText
                    )
                    
                    summaryRow(
                        label: "Total Amount",
                        value: currencyManager.currentCurrency.format(Decimal(summaryData.totalAmount)),
                        valueColor: Color.expenseGreen
                    )
                    
                    summaryRow(
                        label: "Average Amount",
                        value: currencyManager.currentCurrency.format(Decimal(summaryData.averageAmount)),
                        valueColor: Color(red: 1.0, green: 0.596, blue: 0.0) // #FF9800
                    )
                }
            }
        }
    }
    
    // MARK: - Today's Summary Card
    private var todaySummaryCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 8) {
                    summaryRow(
                        label: "Today's Expenses",
                        value: "\(summaryData.todayExpenseCount)",
                        valueColor: .expensePrimaryText
                    )
                    
                    summaryRow(
                        label: "Today's Total",
                        value: currencyManager.currentCurrency.format(Decimal(summaryData.todayTotalAmount)),
                        valueColor: Color.expenseGreen
                    )
                }
            }
        }
    }
    
    // MARK: - Weekly Summary Card
    private var weeklySummaryCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("This Week's Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 8) {
                    summaryRow(
                        label: "This Week's Expenses",
                        value: "\(summaryData.weeklyExpenseCount)",
                        valueColor: .expensePrimaryText
                    )
                    
                    summaryRow(
                        label: "This Week's Total",
                        value: currencyManager.currentCurrency.format(Decimal(summaryData.weeklyTotalAmount)),
                        valueColor: Color.expenseGreen
                    )
                }
            }
        }
    }
    
    // MARK: - Monthly Summary Card
    private var monthlySummaryCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("This Month's Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 8) {
                    summaryRow(
                        label: "This Month's Expenses",
                        value: "\(summaryData.monthlyExpenseCount)",
                        valueColor: .expensePrimaryText
                    )
                    
                    summaryRow(
                        label: "This Month's Total",
                        value: currencyManager.currentCurrency.format(Decimal(summaryData.monthlyTotalAmount)),
                        valueColor: Color.expenseGreen
                    )
                }
            }
        }
    }
    
    // MARK: - Extremes Card
    private var extremesCard: some View {
        InlineGlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Expense Extremes")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Highest Expense")
                            .font(.subheadline)
                            .foregroundColor(.expenseSecondaryText)
                        
                        Spacer()
                        
                        Text(currencyManager.currentCurrency.format(Decimal(summaryData.highestExpenseAmount)))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.expensePrimaryText)
                    }
                    
                    HStack {
                        Text("Lowest Expense")
                            .font(.subheadline)
                            .foregroundColor(.expenseSecondaryText)
                        
                        Spacer()
                        
                        Text(currencyManager.currentCurrency.format(Decimal(summaryData.lowestExpenseAmount)))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.expensePrimaryText)
                    }
                }
            }
        }
    }
    
    // MARK: - Load Summary Data
    private func loadSummaryData() {
        let expenses = loadExpenses()
        
        // Calculate overall statistics
        summaryData.totalExpenseCount = expenses.count
        summaryData.totalAmount = expenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }
        summaryData.averageAmount = expenses.isEmpty ? 0 : summaryData.totalAmount / Double(expenses.count)
        
        // Calculate today's statistics
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let todayExpenses = expenses.filter { $0.date >= today && $0.date < tomorrow }
        summaryData.todayExpenseCount = todayExpenses.count
        summaryData.todayTotalAmount = todayExpenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }
        
        // Calculate weekly statistics
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
            let weeklyExpenses = expenses.filter { $0.date >= weekInterval.start && $0.date < weekInterval.end }
            summaryData.weeklyExpenseCount = weeklyExpenses.count
            summaryData.weeklyTotalAmount = weeklyExpenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }
        }
        
        // Calculate monthly statistics
        if let monthInterval = calendar.dateInterval(of: .month, for: Date()) {
            let monthlyExpenses = expenses.filter { $0.date >= monthInterval.start && $0.date < monthInterval.end }
            summaryData.monthlyExpenseCount = monthlyExpenses.count
            summaryData.monthlyTotalAmount = monthlyExpenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }
        }
        
        // Calculate extremes
        if !expenses.isEmpty {
            let sortedByPrice = expenses.sorted { $0.price > $1.price }
            if let highest = sortedByPrice.first {
                summaryData.highestExpenseAmount = NSDecimalNumber(decimal: highest.price).doubleValue
                summaryData.highestExpenseName = highest.name
            }
            if let lowest = sortedByPrice.last {
                summaryData.lowestExpenseAmount = NSDecimalNumber(decimal: lowest.price).doubleValue
                summaryData.lowestExpenseName = lowest.name
            }
        }
    }
    
    private func loadExpenses() -> [ExpenseItem] {
        let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] ?? []
        return dictArray.compactMap { ExpenseItem.fromDictionary($0) }
    }
    
    // MARK: - Summary Row Helper
    private func summaryRow(label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.expenseSecondaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Currency Settings View
struct CurrencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var showingRateDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    currentStatusCard
                    
                    // Currency Selection
                    currencySelectionCard
                    
                    // Exchange Rates Card
                    exchangeRatesCard
                    
                    // API Status Card
                    apiStatusCard
                    
                    Spacer(minLength: 20)
                }
                .padding(16)
            }
            .background(Color.expenseBackground)
            .navigationTitle("Currency Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.expenseAccent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { currencyManager.fetchExchangeRates() }) {
                        if currencyManager.isLoadingRates {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.expenseAccent)
                        }
                    }
                    .disabled(currencyManager.isLoadingRates)
                }
            }
        }
        .onAppear {
            if currencyManager.exchangeRates.isEmpty {
                currencyManager.fetchExchangeRates()
            }
        }
    }
    
    // MARK: - Card Views
    private var currentStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💱 Current Currency")
                    .font(.headline)
                    .foregroundColor(.expensePrimaryText)
                
                Spacer()
                
                if currencyManager.isLoadingRates {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            HStack(spacing: 12) {
                Text(currencyManager.currentCurrency.flag)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currencyManager.currentCurrency.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.expensePrimaryText)
                    
                    Text("\(currencyManager.currentCurrency.symbol) \(currencyManager.currentCurrency.code)")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.expenseGreen)
                        )
                    
                    if let lastUpdate = currencyManager.lastUpdateTime {
                        Text("Updated \(timeAgoString(from: lastUpdate))")
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.expenseCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.expenseAccent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var currencySelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🌍 Available Currencies")
                .font(.headline)
                .foregroundColor(.expensePrimaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(CurrencyManager.Currency.allCurrencies) { currency in
                    CurrencySelectionRow(
                        currency: currency,
                        isSelected: currency.code == currencyManager.currentCurrency.code,
                        exchangeRate: currencyManager.exchangeRates[currency.code]
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currencyManager.setCurrency(currency)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.expenseCardBackground)
        )
    }
    
    private var exchangeRatesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📊 Exchange Rates")
                    .font(.headline)
                    .foregroundColor(.expensePrimaryText)
                
                Spacer()
                
                Button("View All") {
                    showingRateDetails = true
                }
                .font(.caption)
                .foregroundColor(.expenseAccent)
            }
            
            if currencyManager.exchangeRates.isEmpty {
                Text("Loading exchange rates...")
                    .font(.subheadline)
                    .foregroundColor(.expenseSecondaryText)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(currencyManager.exchangeRates.prefix(3).sorted(by: { $0.key < $1.key })), id: \.key) { code, rate in
                        if let currency = CurrencyManager.Currency.allCurrencies.first(where: { $0.code == code }) {
                            HStack {
                                Text("\(currency.flag) \(code)")
                                    .font(.subheadline)
                                    .foregroundColor(.expensePrimaryText)
                                
                                Spacer()
                                
                                Text("1 USD = \(currency.symbol)\(String(format: "%.2f", rate))")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.expenseCardBackground)
        )
        .sheet(isPresented: $showingRateDetails) {
            ExchangeRateDetailsView()
        }
    }
    
    private var apiStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔄 API Status")
                .font(.headline)
                .foregroundColor(.expensePrimaryText)
            
            if let error = currencyManager.apiError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.expenseError)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.expenseError)
                        .multilineTextAlignment(.leading)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.expenseGreen)
                    
                    Text("Myanmar Currency API - Connected")
                        .font(.caption)
                        .foregroundColor(.expenseGreen)
                }
            }
            
            Text("https://myanmar-currency-api.github.io/api/latest.json")
                .font(.caption2)
                .foregroundColor(.expenseSecondaryText)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.expenseCardBackground)
        )
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Currency Selection Row
struct CurrencySelectionRow: View {
    let currency: CurrencyManager.Currency
    let isSelected: Bool
    let exchangeRate: Double?
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                HStack {
                    Text(currency.flag)
                        .font(.title2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.expenseGreen)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.expensePrimaryText)
                    
                    if let rate = exchangeRate {
                        Text("1 USD = \(currency.symbol)\(String(format: "%.2f", rate))")
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)
                    } else if currency.code == "USD" {
                        Text("Base currency")
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.expenseAccent.opacity(0.1) : Color.expenseInputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.expenseAccent : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Exchange Rate Details View
struct ExchangeRateDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(CurrencyManager.Currency.allCurrencies) { currency in
                    HStack {
                        Text(currency.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currency.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.expensePrimaryText)
                            
                            Text(currency.code)
                                .font(.caption)
                                .foregroundColor(.expenseSecondaryText)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            if currency.code == "USD" {
                                Text("Base Currency")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.expenseAccent)
                            } else if let rate = currencyManager.exchangeRates[currency.code] {
                                Text("\(currency.symbol)\(String(format: "%.2f", rate))")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.expensePrimaryText)
                                
                                Text("per 1 USD")
                                    .font(.caption2)
                                    .foregroundColor(.expenseSecondaryText)
                            } else {
                                Text("Loading...")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Exchange Rates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Summary Data Structure
struct InlineSummaryData {
    var totalExpenseCount: Int = 0
    var totalAmount: Double = 0.0
    var averageAmount: Double = 0.0
    var todayExpenseCount: Int = 0
    var todayTotalAmount: Double = 0.0
    var weeklyExpenseCount: Int = 0
    var weeklyTotalAmount: Double = 0.0
    var monthlyExpenseCount: Int = 0
    var monthlyTotalAmount: Double = 0.0
    var highestExpenseAmount: Double = 0.0
    var lowestExpenseAmount: Double = 0.0
    var highestExpenseName: String = ""
    var lowestExpenseName: String = ""
}

// MARK: - Inline Glassmorphism Card
struct InlineGlassmorphismCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.expenseCardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
    }
}


