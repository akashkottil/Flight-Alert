//
//  NetworkManager.swift
//  FligthAlert
//
//  Created by Akash Kottil on 28/06/25.
//


import Foundation
import Combine

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let baseURL = "https://staging.flight.lascade.com"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Generic API Call Method
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        
        guard let url = createURL(endpoint: endpoint, parameters: method == .GET ? parameters : nil) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body for POST requests
        if method == .POST, let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                return Fail(error: NetworkError.encodingError)
                    .eraseToAnyPublisher()
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - URL Creation
    private func createURL(endpoint: String, parameters: [String: Any]?) -> URL? {
        guard let baseURL = URL(string: baseURL) else { return nil }
        let url = baseURL.appendingPathComponent(endpoint)
        
        guard let parameters = parameters, !parameters.isEmpty else {
            return url
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        return components?.url
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError
    case encodingError
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .noData:
            return "No data received"
        }
    }
}