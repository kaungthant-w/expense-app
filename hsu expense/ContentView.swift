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

// MARK: - Design System Colors
extension Color {
    static let expenseBackground = Color(.systemBackground)
    static let expenseCardBackground = Color(.secondarySystemBackground)
    static let expensePrimaryText = Color(.label)
    static let expenseSecondaryText = Color(.secondaryLabel)
    static let expenseAccent = Color(.systemBlue)
    static let expenseError = Color(.systemRed)
    static let expenseInputBackground = Color(.tertiarySystemBackground)
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var expenses: [ExpenseItem] = []
    @State private var showingAddExpense = false
    @State private var selectedExpense: ExpenseItem?
    @State private var totalExpenses: Decimal = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.expenseBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Summary Card
                        summaryCardView
                        
                        // Expense List
                        expenseListView
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Image("ExpenseLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text("My Expenses")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.expensePrimaryText)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.expenseAccent)
                    }
                    .accessibilityLabel("Add new expense")
                }
            }
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
            loadSampleData()
            calculateTotal()
        }
    }
    
    // MARK: - Summary Card View
    private var summaryCardView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Expenses")
                        .font(.subheadline)
                        .foregroundColor(.expenseSecondaryText)
                    
                    Text(formatCurrency(totalExpenses))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.expenseSecondaryText)
                    
                    Text("\(expenses.count) items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.expenseAccent)
                }
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                StatItemView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average",
                    value: expenses.isEmpty ? "$0" : formatCurrency(totalExpenses / Decimal(expenses.count))
                )
                
                Spacer()
                
                StatItemView(
                    icon: "calendar",
                    title: "Today",
                    value: "\(todayExpensesCount)"
                )
                
                Spacer()
                
                StatItemView(
                    icon: "arrow.up.circle",
                    title: "Highest",
                    value: expenses.isEmpty ? "$0" : formatCurrency(expenses.map { $0.price }.max() ?? 0)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.expenseCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.bottom, 24)
    }
    
    // MARK: - Expense List View
    private var expenseListView: some View {
        LazyVStack(spacing: 12) {
            if expenses.isEmpty {
                EmptyStateView {
                    showingAddExpense = true
                }
            } else {
                ForEach(expenses) { expense in
                    ExpenseRowView(expense: expense) {
                        selectedExpense = expense
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var todayExpensesCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return expenses.filter { expense in
            expense.date >= today && expense.date < tomorrow
        }.count
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
    
    private func addExpense(_ expense: ExpenseItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            expenses.append(expense)
            calculateTotal()
        }
    }
    
    private func updateExpense(_ updatedExpense: ExpenseItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                expenses[index] = updatedExpense
                calculateTotal()
            }
        }
    }
    
    private func deleteExpense(_ expense: ExpenseItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            expenses.removeAll { $0.id == expense.id }
            calculateTotal()
        }
    }
    
    private func loadSampleData() {
        // Sample data for demonstration
        expenses = [
            ExpenseItem(name: "Grocery Shopping", price: 85.50, description: "Weekly groceries from supermarket", date: Date(), time: Date()),
            ExpenseItem(name: "Gas Station", price: 45.00, description: "Fuel for car", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), time: Date()),
            ExpenseItem(name: "Restaurant Lunch", price: 28.75, description: "Lunch with colleagues", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), time: Date()),
            ExpenseItem(name: "Coffee Shop", price: 5.50, description: "Morning coffee", date: Date(), time: Date()),
            ExpenseItem(name: "Movie Tickets", price: 24.00, description: "Cinema tickets for two", date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), time: Date())
        ]
        calculateTotal()
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
            HStack(spacing: 16) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(Color.expenseAccent.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(categoryIconName(for: expense.name))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.expenseAccent)
                }
                
                // Expense Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.expensePrimaryText)
                        .lineLimit(1)
                    
                    if !expense.description.isEmpty {
                        Text(expense.description)
                            .font(.caption)
                            .foregroundColor(.expenseSecondaryText)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 8) {
                        Text(expense.formattedDate)
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)
                        
                        Text(expense.formattedTime)
                            .font(.caption2)
                            .foregroundColor(.expenseSecondaryText)
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text(expense.formattedPrice)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.expensePrimaryText)
                    
                    Text(expense.currency)
                        .font(.caption2)
                        .foregroundColor(.expenseSecondaryText)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.expenseCardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIconName(for name: String) -> String {
        let lowercaseName = name.lowercased()
        if lowercaseName.contains("food") || lowercaseName.contains("restaurant") || lowercaseName.contains("grocery") || lowercaseName.contains("lunch") || lowercaseName.contains("coffee") {
            return "CategoryFood"
        } else if lowercaseName.contains("gas") || lowercaseName.contains("fuel") || lowercaseName.contains("car") || lowercaseName.contains("transport") || lowercaseName.contains("taxi") || lowercaseName.contains("uber") {
            return "CategoryTransport"
        } else if lowercaseName.contains("shop") || lowercaseName.contains("store") || lowercaseName.contains("market") || lowercaseName.contains("mall") {
            return "CategoryShopping"
        } else {
            // Default to system icon for general expenses
            return "ExpenseIcon"
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let onAddExpense: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image("ExpenseIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
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
