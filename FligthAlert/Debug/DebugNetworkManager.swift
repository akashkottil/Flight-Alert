////
////  DebugNetworkManager.swift
////  FligthAlert
////
////  Created by Akash Kottil on 28/06/25.
////
//
//
//import Foundation
//import Combine
//
//// MARK: - Debug Network Manager
//class DebugNetworkManager: ObservableObject {
//    static let shared = DebugNetworkManager()
//    private let baseURL = "https://staging.flight.lascade.com"
//    private let session = URLSession.shared
//    
//    private init() {}
//    
//    // MARK: - Debug Method to See Raw Response
//    func debugRequest(query: String) -> AnyPublisher<String, NetworkError> {
//        let endpoint = "v1/airports/"
//        let parameters = [
//            "q": query,
//            "limit": "10",
//            "page": "1"
//        ]
//        
//        guard let url = createURL(endpoint: endpoint, parameters: parameters) else {
//            return Fail(error: NetworkError.invalidURL)
//                .eraseToAnyPublisher()
//        }
//        
//        print("🔍 Debug URL: \(url.absoluteString)")
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        return session.dataTaskPublisher(for: request)
//            .map { data, response in
//                // Print HTTP response
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("🌐 HTTP Status: \(httpResponse.statusCode)")
//                    print("📋 Headers: \(httpResponse.allHeaderFields)")
//                }
//                
//                // Print raw response
//                let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode as UTF-8"
//                print("📄 Raw Response: \(rawResponse)")
//                
//                return rawResponse
//            }
//            .mapError { error in
//                print("❌ Network Error: \(error)")
//                return NetworkError.networkError(error)
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    // MARK: - URL Creation (same as original)
//    private func createURL(endpoint: String, parameters: [String: Any]?) -> URL? {
//        guard let baseURL = URL(string: baseURL) else { return nil }
//        let url = baseURL.appendingPathComponent(endpoint)
//        
//        guard let parameters = parameters, !parameters.isEmpty else {
//            return url
//        }
//        
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
//        components?.queryItems = parameters.map { key, value in
//            URLQueryItem(name: key, value: "\(value)")
//        }
//        
//        return components?.url
//    }
//}
//
//// MARK: - Debug ViewModel
//class DebugLocationSearchViewModel: ObservableObject {
//    @Published var debugResponse = ""
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private var cancellables = Set<AnyCancellable>()
//    private let debugNetworkManager = DebugNetworkManager.shared
//    
//    func debugSearch(query: String = "new") {
//        isLoading = true
//        errorMessage = nil
//        debugResponse = ""
//        
//        debugNetworkManager.debugRequest(query: query)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    
//                    switch completion {
//                    case .failure(let error):
//                        self?.errorMessage = error.localizedDescription
//                        print("❌ Debug Error: \(error)")
//                    case .finished:
//                        print("✅ Debug completed")
//                    }
//                },
//                receiveValue: { [weak self] response in
//                    self?.debugResponse = response
//                }
//            )
//            .store(in: &cancellables)
//    }
//}
//
//// MARK: - Test Different Response Structures
//struct PossibleAirportStructure1: Codable {
//    let airports: [AirportOption1]
//}
//
//struct AirportOption1: Codable {
//    let code: String?
//    let iata: String?
//    let iataCode: String?
//    let name: String?
//    let city: String?
//    let cityName: String?
//    let country: String?
//    let countryName: String?
//}
//
//struct PossibleAirportStructure2: Codable {
//    let data: [AirportOption2]
//}
//
//struct AirportOption2: Codable {
//    let iata_code: String?
//    let icao_code: String?
//    let name: String?
//    let city_name: String?
//    let country_name: String?
//    let country_code: String?
//}
//
//struct PossibleAirportStructure3: Codable {
//    let results: [AirportOption3]
//}
//
//struct AirportOption3: Codable {
//    let airport_code: String?
//    let airport_name: String?
//    let city: String?
//    let country: String?
//}
//
//// MARK: - Network Errors (same as before)
//enum NetworkError: Error, LocalizedError {
//    case invalidURL
//    case networkError(Error)
//    case decodingError
//    case encodingError
//    case noData
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "Invalid URL"
//        case .networkError(let error):
//            return "Network error: \(error.localizedDescription)"
//        case .decodingError:
//            return "Failed to decode response"
//        case .encodingError:
//            return "Failed to encode request"
//        case .noData:
//            return "No data received"
//        }
//    }
//}
