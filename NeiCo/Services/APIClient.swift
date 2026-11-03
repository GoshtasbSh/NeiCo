//
//  APIClient.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/22/25.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    let baseURL = "http://127.0.0.1:8000/api/" // Use your backend URL
    var authToken: String? // Set this after login

    // Helper to build requests with auth
    func makeRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }

    func fetchStores(completion: @escaping ([Store]) -> Void) {
        guard let url = URL(string: "\(baseURL)stores/") else {
            completion([])
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }
            do {
                let stores = try JSONDecoder().decode([Store].self, from: data)
                DispatchQueue.main.async {
                    completion(stores)
                }
            } catch {
                print("Decoding error:", error)
                completion([])
            }
        }
        task.resume()
    }

    func fetchItems(for storeId: String, completion: @escaping ([Item]) -> Void) {
        guard let url = URL(string: "\(baseURL)grocery-items/?store=\(storeId)") else {
            completion([])
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }
            do {
                let items = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    completion(items)
                }
            } catch {
                print("Decoding error:", error)
                print("Raw data:", String(data: data, encoding: .utf8) ?? "nil")
                DispatchQueue.main.async { completion([]) }
            }
        }
        task.resume()
    }

    // 1. Fetch grocery list
    func fetchGroceryList(completion: @escaping ([Item]) -> Void) {
        guard let url = URL(string: "\(baseURL)grocery-items/") else { completion([]); return }
        let request = makeRequest(url: url, method: "GET")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion([]); return }
            print("Raw grocery list response: \(String(data: data, encoding: .utf8) ?? "nil")")
            let items = (try? JSONDecoder().decode([Item].self, from: data)) ?? []
            DispatchQueue.main.async { completion(items) }
        }.resume()
    }

    // 2. Add item to grocery list
    func addGroceryItem(_ item: Item, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)grocery-items/") else { completion(false); return }
        let encoder = JSONEncoder()
        guard let body = try? encoder.encode(item) else { completion(false); return }
        let request = makeRequest(url: url, method: "POST", body: body)
        URLSession.shared.dataTask(with: request) { data, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 201
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    // 3. Remove item from grocery list
    func removeItemFromGroceryList(_ itemId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)grocery-items/\(itemId)/") else { completion(false); return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 204
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    // 4. Update item (e.g., quantity)
    func updateItemInGroceryList(_ item: Item, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)grocery-list/\(item.id)/") else { completion(false); return }
        let encoder = JSONEncoder()
        guard let body = try? encoder.encode(item) else { completion(false); return }
        var request = makeRequest(url: url, method: "PATCH", body: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    func fetchStoreItems(for storeId: String, completion: @escaping ([StoreItem]) -> Void) {
        guard let url = URL(string: "\(baseURL)store-items/?store=\(storeId)") else {
            completion([])
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion([]); return }
            let items = (try? JSONDecoder().decode([StoreItem].self, from: data)) ?? []
            DispatchQueue.main.async { completion(items) }
        }.resume()
    }

    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)token/") else {
            completion(false, "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(false, "No data")
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let access = json["access"] as? String,
               let refresh = json["refresh"] as? String {
                // Save tokens
                APIClient.shared.authToken = access
                UserDefaults.standard.set(access, forKey: "authToken")
                UserDefaults.standard.set(refresh, forKey: "refreshToken")
                completion(true, nil)
            } else {
                let errorMsg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["detail"] as? String
                completion(false, errorMsg ?? "Invalid credentials")
            }
        }.resume()
    }

    func logout() {
        // Implementation of logout function
        // This is a placeholder and should be replaced with the actual implementation
        authToken = nil
    }

    func isLoggedIn() -> Bool {
        // Implementation of isLoggedIn function
        // This is a placeholder and should be replaced with the actual implementation
        return authToken != nil
    }

    func setToken(token: String) {
        // Implementation of setToken function
        // This is a placeholder and should be replaced with the actual implementation
        authToken = token
        print("Token set after login: \(token)")
    }
}

