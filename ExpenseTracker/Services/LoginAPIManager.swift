//
//  LoginAPIManager.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 27/02/25.
//

import Foundation

struct LoginUserResponse: Codable {
    let _id: String
    let email: String
    let token: String
}

struct RegisterUserResponse: Codable {
    let _id: String
    let email: String
}

class LoginAPIManager {
    static let shared = LoginAPIManager()
    private let baseURL = "https://expense-tracker-backend-1-9xb7.onrender.com/api/auth"
    private let logoutUser = "https://expense-tracker-backend-1-9xb7.onrender.com/api/auth/logout"
    
    private init() {}

    func registerUser(uuidString: String, email: String, password: String, completion: @escaping (Result<RegisterUserResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password, "_id": uuidString]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let userResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)
                completion(.success(userResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func loginUser(email: String, password: String, completion: @escaping (Result<LoginUserResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let userResponse = try JSONDecoder().decode(LoginUserResponse.self, from: data)
                completion(.success(userResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func logoutUser(completion: @escaping (Bool) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: UserDefaultsKeys.uniqueUserUUID) else {
            print("No user ID found")
            completion(false)
            return
        }
        
        let urlString = "\(logoutUser)\(userID)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" // Logout should use DELETE method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Logout failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Clear UserDefaults on successful logout
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.uniqueUserUUID)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.uniqueAuthToken)
            UserDefaults.standard.synchronize()
            
            completion(true)
        }.resume()
    }
}
