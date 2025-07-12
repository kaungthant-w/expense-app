//
//  SummaryView.swift
//  HSU expense
//
//  Created by kmt on 7/12/25.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var summaryData = SummaryData()
    @Environment(\.dismiss) private var dismiss

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
                dismiss()
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
        GlassmorphismCard {
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
                        value: currencyManager.formatDecimalAmount(Decimal(summaryData.totalAmount)),
                        valueColor: Color.expenseGreen
                    )

                    summaryRow(
                        label: "Average Amount",
                        value: currencyManager.formatDecimalAmount(Decimal(summaryData.averageAmount)),
                        valueColor: Color(red: 1.0, green: 0.596, blue: 0.0) // #FF9800
                    )
                }
            }
        }
    }

    // MARK: - Today's Summary Card
    private var todaySummaryCard: some View {
        GlassmorphismCard {
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
                        value: currencyManager.formatDecimalAmount(Decimal(summaryData.todayTotalAmount)),
                        valueColor: Color.expenseGreen
                    )
                }
            }
        }
    }

    // MARK: - Weekly Summary Card
    private var weeklySummaryCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("This Week's Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)

                VStack(spacing: 8) {
                    summaryRow(
                        label: "This Week's Expenses",
                        value: "\(summaryData.weekExpenseCount)",
                        valueColor: .expensePrimaryText
                    )

                    summaryRow(
                        label: "This Week's Total",
                        value: currencyManager.formatDecimalAmount(Decimal(summaryData.weekTotalAmount)),
                        valueColor: Color.expenseGreen
                    )

                    summaryRow(
                        label: "Average per Day",
                        value: currencyManager.formatDecimalAmount(Decimal(summaryData.weekAveragePerDay)),
                        valueColor: Color(red: 1.0, green: 0.596, blue: 0.0) // #FF9800
                    )
                }
            }
        }
    }

    // MARK: - Monthly Summary Card
    private var monthlySummaryCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("This Month's Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)

                VStack(spacing: 8) {
                    summaryRow(
                        label: "This Month's Expenses",
                        value: "\(summaryData.monthExpenseCount)",
                        valueColor: .expensePrimaryText
                    )

                    summaryRow(
                        label: "This Month's Total",
                        value: currencyManager.formatDecimalAmount(Decimal(summaryData.monthTotalAmount)),
                        valueColor: Color.expenseGreen
                    )
                }
            }
        }
    }

    // MARK: - Extremes Card
    private var extremesCard: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Expense Extremes")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.expensePrimaryText)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Highest Expense")
                            .font(.subheadline)
                            .foregroundColor(.expenseSecondaryText)

                        Text(summaryData.highestExpense.isEmpty ? "No expenses yet" : summaryData.highestExpense)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.expenseError)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lowest Expense")
                            .font(.subheadline)
                            .foregroundColor(.expenseSecondaryText)

                        Text(summaryData.lowestExpense.isEmpty ? "No expenses yet" : summaryData.lowestExpense)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.expenseGreen)
                    }
                }
            }
        }
    }

    // MARK: - Helper Views
    private func summaryRow(label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.expenseSecondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
    }

    // MARK: - Data Loading
    private func loadSummaryData() {
        // Load actual expense data from UserDefaults
        let dictArray = UserDefaults.standard.array(forKey: ExpenseUserDefaultsKeys.expenses) as? [[String: Any]] ?? []
        let expenses = dictArray.compactMap { ExpenseItem.fromDictionary($0) }

        // Calculate overall statistics
        let totalCount = expenses.count
        let totalAmount = expenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }
        let averageAmount = totalCount > 0 ? totalAmount / Double(totalCount) : 0

        // Calculate today's statistics
        let today = DateFormatter.displayDate.string(from: Date())
        let todayExpenses = expenses.filter { expense in
            expense.date == today
        }
        let todayCount = todayExpenses.count
        let todayTotal = todayExpenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }

        // Calculate this week's statistics
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return }
        let weekExpenses = expenses.filter { expense in
            guard let expenseDate = DateFormatter.displayDate.date(from: expense.date) else { return false }
            return expenseDate >= weekInterval.start && expenseDate < weekInterval.end
        }
        let weekCount = weekExpenses.count
        let weekTotal = weekExpenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }
        let weekAveragePerDay = weekTotal / 7.0

        // Calculate this month's statistics
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return }
        let monthExpenses = expenses.filter { expense in
            guard let expenseDate = DateFormatter.displayDate.date(from: expense.date) else { return false }
            return expenseDate >= monthInterval.start && expenseDate < monthInterval.end
        }
        let monthCount = monthExpenses.count
        let monthTotal = monthExpenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.price).doubleValue }

        // Find extremes
        let sortedExpenses = expenses.sorted { NSDecimalNumber(decimal: $0.price).doubleValue > NSDecimalNumber(decimal: $1.price).doubleValue }
        let highest = sortedExpenses.first
        let lowest = sortedExpenses.last

        let highestText = highest != nil ? "\(highest!.name) - \(currencyManager.currentCurrency.format(highest!.price))" : ""
        let lowestText = lowest != nil ? "\(lowest!.name) - \(currencyManager.currentCurrency.format(lowest!.price))" : ""

        summaryData = SummaryData(
            totalExpenseCount: totalCount,
            totalAmount: totalAmount,
            averageAmount: averageAmount,
            todayExpenseCount: todayCount,
            todayTotalAmount: todayTotal,
            weekExpenseCount: weekCount,
            weekTotalAmount: weekTotal,
            weekAveragePerDay: weekAveragePerDay,
            monthExpenseCount: monthCount,
            monthTotalAmount: monthTotal,
            highestExpense: highestText,
            lowestExpense: lowestText
        )
    }
}

// MARK: - Summary Data Model
struct SummaryData {
    var totalExpenseCount: Int = 0
    var totalAmount: Double = 0.0
    var averageAmount: Double = 0.0
    var todayExpenseCount: Int = 0
    var todayTotalAmount: Double = 0.0
    var weekExpenseCount: Int = 0
    var weekTotalAmount: Double = 0.0
    var weekAveragePerDay: Double = 0.0
    var monthExpenseCount: Int = 0
    var monthTotalAmount: Double = 0.0
    var highestExpense: String = ""
    var lowestExpense: String = ""
}

// MARK: - Preview
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
            .preferredColorScheme(.light)

        SummaryView()
            .preferredColorScheme(.dark)
    }
}
