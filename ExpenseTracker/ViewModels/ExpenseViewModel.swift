//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//

import Foundation
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []

    init() {
        loadExpenses()
    }
    
    func addExpense(_ expense: Expense) { // It Will Add Expenses
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            // Update existing expense
            expenses[index] = expense
        } else {
            // Add new expense if it doesn't exist
            expenses.append(expense)
        }
        saveExpense(expense) // Save changes after updating/adding
    }
    
    func saveExpense(_ expense: Expense) { // Save Data on Core Data
        // Save to Core Data
        CoreDataManager.shared.saveExpense(expense)
        fetchExpenses() // Refresh list from Core Data
        
        // Send That Expense Permanently to MongoDB
        ExpenseSyncManager.shared.syncExpense(expense)
    }

    // MARK: - Delete Expense
    func deleteExpense(_ id: UUID) {
        CoreDataManager.shared.deleteExpense(id) // Delete from Core Data
        fetchExpenses() // Refresh the list
        
        // Delete That Expense Permanently to MongoDB
        ExpenseSyncManager.shared.deleteExpense(id)
    }

    func loadExpenses() { // initial Load Expenses
        fetchExpenses()
    }
    
    func fetchExpenses() { // Fetch Expenses
        expenses = CoreDataManager.shared.fetchExpenses()
    }
    
    func getExpenses() -> [Expense] { // Return Expenses
        return expenses
    }

    func addDummyData() { // Add Two Dummy Data Initially
        let dummyExpenses = [
            Expense(id: UUID(), title: "Lunch", amount: 250, category: .food, date: Date()),
            Expense(id: UUID(), title: "Uber", amount: 120, category: .transport, date: Date())
        ]
        
        for expense in dummyExpenses {
            saveExpense(expense)
        }
    }
}
