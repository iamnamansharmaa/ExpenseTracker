//
//  ExpenseSyncManager.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 25/02/25.
//

import Foundation
import CoreData

class ExpenseSyncManager {
    static let shared = ExpenseSyncManager()

    private init() {}

    func syncExpense(_ expense: Expense) {
        let expenseDTO = ExpenseDTO(
            userUUID: expense.userUUID,
            id: expense.id.uuidString,
            title: expense.title,
            amount: expense.amount,
            category: expense.category.rawValue,
            date: ISO8601DateFormatter().string(from: expense.date)
        )
        
        APIManager.shared.checkExpenseExists(expenseID: expenseDTO.id) { exists in
            if exists {
                self.updateExpense(expenseDTO)
            } else {
                self.createExpense(expenseDTO)
            }
        }
    }

    func updateExpense(_ expenseDTO: ExpenseDTO) {
        APIManager.shared.postRequest(url: API.updateExpenses, body: expenseDTO) { result in
            switch result {
            case .success:
                print("✅ Expense updated successfully!")
            case .failure(let error):
                print("❌ Failed to update expense: \(error.localizedDescription)")
            }
        }
    }

    func createExpense(_ expenseDTO: ExpenseDTO) {
        APIManager.shared.postRequest(url: API.createExpenses, body: expenseDTO) { result in
            switch result {
            case .success:
                print("✅ Expense created successfully!")
            case .failure(let error):
                print("❌ Failed to create expense: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteExpense(_ id: UUID) {
        let expenseID = id.uuidString
        APIManager.shared.deleteRequest(url: "\(API.deleteExpense)/\(expenseID)") { result in
            switch result {
            case .success:
                print("✅ Expense deleted successfully from backend!")
            case .failure(let error):
                print("❌ Failed to delete expense from backend: \(error.localizedDescription)")
            }
        }
    }

    func syncExpenses() {
        let localExpenses = CoreDataManager.shared.fetchExpenses()

        guard !localExpenses.isEmpty else {
            print("✅ No new expenses to sync")
            return
        }

        let expensesDTO = localExpenses.map { expense in
            ExpenseDTO(
                userUUID: expense.userUUID,
                id: expense.id.uuidString,
                title: expense.title,
                amount: expense.amount,
                category: (expense.category).rawValue,
                date: ISO8601DateFormatter().string(from: expense.date)
            )
        }

        APIManager.shared.postRequest(url: API.syncExpenses, body: expensesDTO) { result in
            switch result {
            case .success:
                print("✅ Sync Successful")
            case .failure(let error):
                print("❌ Sync Failed: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchExpensesFromBackend(completion: @escaping (Bool) -> Void) {
        guard let useUUID = UserDefaults.standard.string(forKey: UserDefaultsKeys.uniqueUserUUID) else {
            print("UUID is Missing in UserDefaults")
            completion(false)
            return
        }
        APIManager.shared.fetchExpenses(url: "\(API.syncExpenses)/\(useUUID)") { result in
            switch result {
            case .success(let expenses):
                print("✅ Fetched Expenses:", expenses)
                self.saveExpensesToCoreData(expenses)
                completion(true)
            case .failure(let error):
                print("❌ Fetch Failed: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    private func saveExpensesToCoreData(_ expenses: [ExpenseDTO]) {
        //  Clear existing Core Data before inserting new data (optional)
        
        let existingExpenses = CoreDataManager.shared.fetchExpenses()
        for expense in existingExpenses {
            CoreDataManager.shared.deleteExpense(expense.id)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Insert new expenses from API
        for expenseDTO in expenses {
            guard let expenseID = UUID(uuidString: expenseDTO.id) else {
                print("❌ Error converting UUID")
                continue
            }
            
            guard let expenseDate = dateFormatter.date(from: expenseDTO.date) else {
                print("❌ Error parsing date: \(expenseDTO.date)")
                continue
            }
            
            let newExpense = Expense(
                userUUID: expenseDTO.userUUID,
                id: expenseID,
                title: expenseDTO.title,
                amount: expenseDTO.amount,
                category: ExpenseCategory(rawValue: expenseDTO.category) ?? .other,
                date: expenseDate
            )
            CoreDataManager.shared.saveExpense(newExpense)
        }
        
        print("✅ Expenses saved to Core Data!")
    }
}
