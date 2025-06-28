import Foundation
import Combine

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

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let baseURL = "https://staging.flight.lascade.com"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Airport Search Method
    func requestAirports(query: String) -> AnyPublisher<[Airport], NetworkError> {
        let parameters = [
            "q": query,
            "limit": "10",
            "page": "1"
        ]
        
        guard let url = createURL(endpoint: "v1/airports/", parameters: parameters) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        print("🌐 Making request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        return session.dataTaskPublisher(for: request)
            .timeout(.seconds(10), scheduler: DispatchQueue.main)
            .map { data, response -> Data in
                // Log response details
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("⚠️ Unexpected status code: \(httpResponse.statusCode)")
                    }
                }
                
                // Log raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Raw Response: \(jsonString)")
                } else {
                    print("❌ Could not convert response to string")
                }
                
                return data
            }
            .tryMap { data -> [Airport] in
                let decoder = JSONDecoder()
                
                // Try different response formats in order of likelihood
                
                // Format 1: Direct array
                if let airports = try? decoder.decode([Airport].self, from: data) {
                    print("✅ Successfully decoded as direct array")
                    return airports
                }
                
                // Format 2: { "data": [...] }
                if let response = try? decoder.decode(AirportDataResponse.self, from: data) {
                    print("✅ Successfully decoded with 'data' wrapper")
                    return response.data
                }
                
                // Format 3: { "results": [...] }
                if let response = try? decoder.decode(AirportResultsResponse.self, from: data) {
                    print("✅ Successfully decoded with 'results' wrapper")
                    return response.results
                }
                
                // Format 4: { "airports": [...] }
                if let response = try? decoder.decode(AirportWrapperResponse.self, from: data) {
                    print("✅ Successfully decoded with 'airports' wrapper")
                    return response.airports
                }
                
                // If all formats fail, log the error and throw
                print("❌ Failed to decode with any known format")
                print("💡 This usually means the API response structure is different from expected")
                throw NetworkError.decodingError
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    print("❌ Unexpected error: \(error)")
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Generic API Call Method (for future use)
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
