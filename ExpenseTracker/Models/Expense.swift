//
//  Expense.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//
import Foundation

enum ExpenseCategory: String, Codable, CaseIterable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case other = "Other"
}

struct Expense: Identifiable, Codable {
    var userUUID: String = UserDefaults.standard.string(forKey: UserDefaultsKeys.uniqueUserUUID) ?? ""
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    
    var isEditable: Bool { // it will true if date is not 4 days back
        let calendar = Calendar.current
        guard let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: Date()) else { return false }
        return date >= fourDaysAgo
    }
}

struct UserDefaultsKeys {
    static let uniqueUserUUID = "userUUID"
    static let uniqueAuthToken = "authToken"
}
