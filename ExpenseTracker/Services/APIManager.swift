//
//  APIManager.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 25/02/25.
//

import Foundation

struct API {
    static let baseURL = "https://expense-tracker-backend-1-9xb7.onrender.com/api"
    static let syncExpenses = "\(baseURL)/expenses/sync"
    static let fetchExpenses = "\(baseURL)/expenses"
    static let updateExpenses = "\(baseURL)/expenses/update"
    static let createExpenses = "\(baseURL)/expenses/create"
    static let deleteExpense = "\(baseURL)/expenses/delete"
}

class APIManager {
    static let shared = APIManager()
    
    private init() {} // Singleton instance
    
    func postRequest<T: Codable>(url: String, body: T, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let requestURL = URL(string: url) else { return }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
    
    func checkExpenseExists(expenseID: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(API.fetchExpenses)/\(expenseID)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Failed to check expense: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true) // Expense exists
            } else {
                completion(false) // Expense does not exist
            }
        }.resume()
    }
    
    func deleteRequest(url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let requestURL = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }
    
    func fetchExpenses(url: String, completion: @escaping (Result<[ExpenseDTO], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let expenses = try decoder.decode([ExpenseDTO].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(expenses))
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Decoding Error:", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
