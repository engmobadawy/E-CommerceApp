
//
//  Created by MohamedBadawi on 19/08/2025.
//

//
//  NetworkManager.swift
//  E-CommerceAppLoginPage
//

import Foundation
import SwiftKeychainWrapper

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: [String: Any]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: API.baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Attach token from Keychain
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode body for POST/PUT
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Network Error
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            // Error status codes
            switch httpResponse.statusCode {
            case 200...299:
                break // OK
            case 401:
                completion(.failure(.unauthorized)); return
            case 403:
                completion(.failure(.forbidden)); return
            case 404:
                completion(.failure(.notFound)); return
            case 500...599:
                completion(.failure(.serverError)); return
            default:
                // Try to decode backend error JSON
                if let data = data,
                   let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
                   let message = serverError.message {
                    completion(.failure(.custom(message: message)))
                } else {
                    completion(.failure(.custom(message: "Unexpected status code: \(httpResponse.statusCode)")))
                }
                return
            }
            
            // Data Validation
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // JSON Decoding
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }
    
    // MARK: - Login Request
    func login(username: String, password: String, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        request(endpoint: API.Endpoints.login, method: .post, body: body) { (result: Result<LoginResponse, APIError>) in
            switch result {
            case .success(let response):
                
                    KeychainWrapper.standard.set(response.token, forKey: "authToken")
                
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        KeychainWrapper.standard.removeObject(forKey: "authToken")
    }
}
