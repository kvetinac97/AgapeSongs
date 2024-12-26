//
//  NetworkService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import Foundation

/// Interface capable of handling network requests
protocol NetworkServicing {
    /// Perform HTTP GET method with cache
    func get (url: String) async -> Result<Data, HttpStatusError>
    
    /// Perform HTTP GET method, cache will be used if `cache` parameter is true
    func get (url: String, cache: Bool) async -> Result<Data, HttpStatusError>
    
    /// Perform HTTP DELETE method
    func delete (url: String) async -> Result<Data, HttpStatusError>
    
    /// Perform HTTP POST method
    func post<T: Encodable> (url: String, body: T) async -> Result<Data, HttpStatusError>
    
    /// Perform HTTP PATCH method
    func patch<T: Encodable> (url: String, body: T) async -> Result<Data, HttpStatusError>
    
    /// Perform HTTP PUT method
    func put<T: Encodable> (url: String, body: T) async -> Result<Data, HttpStatusError>
}

/// Helper DI protocol
protocol HasNetworkService {
    var networkService: NetworkServicing { get }
}

struct NetworkService: NetworkServicing {
    
    private let authService: AuthServicing
    
    init(authService: AuthServicing) {
        self.authService = authService
    }
    
    // MARK: - Protocol method implementation
    
    func get(url: String) async -> Result<Data, HttpStatusError> {
        await get(url: url, cache: true)
    }
    
    func get(url: String, cache: Bool) async -> Result<Data, HttpStatusError> {
        let result = await fetch(url: url, method: "GET", body: String?(nil))
        
        if cache {
            switch result {
            // If cache is enabled and failed due to network error, try loading from cache
            case .failure(let error):
                if case .network = error,
                   let cachedResult = UserDefaults.standard.data(forKey: "network_\(url)") {
                    print("📶 \(url) Loading data response from cache")
                    return .success(cachedResult)
                }
            // If cache is enabled and succeeded, save to cache
            case .success(let data):
                print("📶 \(url) Saving response to cache")
                UserDefaults.standard.set(data, forKey: "network_\(url)")
            }
        }
        
        return result
    }
    
    func delete(url: String) async -> Result<Data, HttpStatusError> {
        await fetch(url: url, method: "DELETE", body: String?(nil))
    }
    
    func post<T: Encodable>(url: String, body: T) async -> Result<Data, HttpStatusError> {
        await fetch(url: url, method: "POST", body: body)
    }
    
    func patch<T: Encodable>(url: String, body: T) async -> Result<Data, HttpStatusError> {
        await fetch(url: url, method: "PATCH", body: body)
    }
    
    func put<T: Encodable>(url: String, body: T) async -> Result<Data, HttpStatusError> {
        await fetch(url: url, method: "PUT", body: body)
    }
    
    // MARK: - Private helpers
    
    private func fetch<T: Encodable>(url: String, method: String, body: T?) async -> Result<Data, HttpStatusError> {
        guard let url = URL(string: Constants.apiLocation + url) else {
            print("❌ Invalid request URL \(Constants.apiLocation + url)")
            return .failure(.badtext(text: "invalid_request_url_error"))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Do not show loading for too long
        if method == "GET" {
            request.timeoutInterval = Constants.requestGetTimeout
        }
        
        if let body = body {
            do {
                request.allHTTPHeaderFields = ["Content-Type": "application/json"]
                request.httpBody = try JSONEncoder().encode(body)
            }
            catch {
                return .failure(.badtext(text: error.localizedDescription))
            }
        }
        
        if let user = authService.user {
            request.addValue(user.loginSecret, forHTTPHeaderField: Constants.loginSecretHeader)
        }
        
        return await fetch(request: request)
    }
    
    private func fetch(request: URLRequest) async -> Result<Data, HttpStatusError> {
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse else {
                  return .failure(.network)
        }
        if httpResponse.statusCode < 200 || httpResponse.statusCode > 204 {
            return .failure(.badcode(code: httpResponse.statusCode))
        }
        return .success(data)
    }
    
    // MARK: - Constants
    
    enum Constants {
        static let apiLocation = "https://kvetinac97.cz:8443"
        static let requestGetTimeout = 5.0
        fileprivate static let loginSecretHeader = "LOGIN_SECRET"
    }
}

/// Helper enum class for HTTP error handling
enum HttpStatusError: Error, Identifiable, LocalizedError {
    case badcode (code: Int)
    case badtext (text: String)
    case network
    
    var id: String {
        switch self {
        case let .badcode(code: code):
            return String(code)
        case let .badtext(text: text):
            return text
        case .network:
            return "no_connection_error"
        }
    }
    
    var errorDescription: String {
        switch self {
        case let .badcode(code):
            return NSLocalizedString("http_error_\(code)", comment: "")
        case let .badtext(text: text):
            return NSLocalizedString(text, comment: "")
        case .network:
            return NSLocalizedString("no_connection_error", comment: "")
        }
    }
}

// Implementation for DI
private let _networkService = NetworkService(authService: context.authService)

extension DI: HasNetworkService {
    var networkService: NetworkServicing { _networkService }
}
