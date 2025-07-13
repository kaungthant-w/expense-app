// Add this function to ContentView or create a helper for testing
func importMixedCurrencyTestData() {
    let testExpenses = [
        ExpenseItem(
            id: UUID().uuidString,
            name: "Coffee Shop",
            price: 50.0,
            description: "Morning coffee and pastry",
            date: "2025-07-13",
            time: "08:30 AM",
            currency: "USD"
        ),
        ExpenseItem(
            id: UUID().uuidString,
            name: "Local Food",
            price: 2000.0,
            description: "Myanmar local restaurant",
            date: "2025-07-13",
            time: "12:30 PM",
            currency: "MMK"
        ),
        ExpenseItem(
            id: UUID().uuidString,
            name: "Museum Ticket",
            price: 30.0,
            description: "Art museum entrance fee",
            date: "2025-07-13",
            time: "02:15 PM",
            currency: "EUR"
        )
    ]

    // Convert to dictionary format and save
    let dictArray = testExpenses.map { $0.toDictionary() }
    UserDefaults.standard.set(dictArray, forKey: ExpenseUserDefaultsKeys.expenses)
    print("✅ Mixed currency test data imported!")
}
