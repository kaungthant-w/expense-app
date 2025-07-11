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
//  hsu expense
//
//  Created by kmt on 7/9/25.
//

import SwiftUI
import CoreData

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
        formatter.maximumFractionDigits = 2
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
        ZStack {
            // Try to load the custom image first
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            } else {
                // Fallback to system image
                Image(systemName: systemFallback)
                    .font(.system(size: min(width, height) * 0.6))
                    .frame(width: width, height: height)
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
    
    var body: some View {
        ZStack {
            // Main Content (equivalent to CoordinatorLayout)
            NavigationView {
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
            }
            
            // Floating Action Button (equivalent to DraggableFloatingActionButton)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4)) // Dark gray icon
                            .frame(width: 56, height: 56)
                            .background(Color(red: 0.933, green: 0.933, blue: 0.933)) // Light gray background #EEEEEE
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Add expense")
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingNavigationDrawer) {
            NavigationDrawerView()
        }
        .sheet(isPresented: $showSettingsPage) {
            SettingsPage()
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
        .onAppear {
            loadExpensesFromUserDefaults()
            calculateTotal()
            // debugTabData() // Debug information - can be removed later
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowSettingsPage"), object: nil, queue: .main) { _ in
                showSettingsPage = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ReloadExpensesFromUserDefaults"), object: nil, queue: .main) { _ in
                loadExpensesFromUserDefaults()
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
                    Text("$" + String(format: "%.2f", NSDecimalNumber(decimal: todayTotalAmount).doubleValue))
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
                        Text(tabTitle(for: index))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedTab == index ? Color.expensePrimaryText : Color.expenseSecondaryText)
                        
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
            // All Expenses Tab (3 years of data)
            allExpenseListView
                .tag(0)
            
            // Today's Expenses Tab
            todayExpenseListView
                .tag(1)
            
            // This Week's Expenses Tab
            thisWeekExpenseListView
                .tag(2)
            
            // This Month's Expenses Tab
            thisMonthExpenseListView
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
        case 0: return "ALL"
        case 1: return "TODAY"
        case 2: return "THIS WEEK"
        case 3: return "THIS MONTH"
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
        print("Total expenses: \(expenses.count)")
        print("Today expenses: \(todayExpenses.count)")
        print("This week expenses: \(thisWeekExpenses.count)")
        print("This month expenses: \(thisMonthExpenses.count)")
        print("All expenses (3 years): \(allExpenses.count)")
        
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
                    // Price (show as $2.00 style)
                    Text("$" + String(format: "%.2f", NSDecimalNumber(decimal: expense.price).doubleValue))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.expenseAccent)
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
    @State private var expense: ExpenseItem
    @State private var isNewExpense: Bool
    let onSave: (ExpenseItem) -> Void
    
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    
    init(expense: ExpenseItem?, onSave: @escaping (ExpenseItem) -> Void) {
        if let expense = expense {
            self._expense = State(initialValue: expense)
            self._isNewExpense = State(initialValue: false)
        } else {
            self._expense = State(initialValue: ExpenseItem())
            self._isNewExpense = State(initialValue: true)
        }
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
                        
                        // Price Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.expenseAccent)
                                Text("Price")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                            }
                            
                            HStack {
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
                                
                                Text("USD")
                                    .font(.caption)
                                    .foregroundColor(.expenseSecondaryText)
                                    .padding(.leading, 8)
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
        }
    }
    
    private func saveExpense() {
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

// MARK: - Navigation Drawer View (equivalent to NavigationView)
struct NavigationDrawerView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    SafeImage(
                        imageName: "ExpenseLogo",
                        systemFallback: "dollarsign.circle.fill",
                        width: 60,
                        height: 60
                    )
                    .clipShape(Circle())
                    .foregroundColor(.white)
                    
                    Text("HSU Expense")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Expense Tracker")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.expenseAccent)
                
                // Menu Items
                VStack(spacing: 0) {
                    NavigationMenuItem(icon: "house.fill", title: "Home") {
                        dismiss()
                    }
                    NavigationMenuItem(icon: "chart.bar.fill", title: "Reports") {
                        dismiss()
                    }
                    NavigationMenuItem(icon: "gear", title: "Settings") {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            NotificationCenter.default.post(name: NSNotification.Name("ShowSettingsPage"), object: nil)
                        }
                    }
                    NavigationMenuItem(icon: "info.circle", title: "About") {
                        dismiss()
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color.expenseCardBackground)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Navigation Menu Item
struct NavigationMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.expenseAccent)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.expensePrimaryText)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
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


