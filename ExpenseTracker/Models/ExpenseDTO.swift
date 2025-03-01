//
//  ExpenseDTO.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 25/02/25.
//

struct ExpenseDTO: Codable {
    var userUUID: String
    let id: String
    let title: String
    let amount: Double
    let category: String
    let date: String  // Keep it as String initially to debug

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, amount, category, date, userUUID
    }
}
