import Foundation
import Combine
import SwiftUI

// MARK: - Location Search ViewModel
class LocationSearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var originText = ""
    @Published var destinationText = ""
    @Published var searchResults: [Airport] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedOrigin: Airport?
    @Published var selectedDestination: Airport?
    @Published var debugInfo = ""
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    private var searchTask: AnyCancellable?
    
    // MARK: - Search States
    enum SearchField {
        case origin
        case destination
    }
    
    @Published var activeField: SearchField = .origin
    
    // MARK: - Initialization
    init() {
        setupSearchObservers()
    }
    
    // MARK: - Setup Search Observers
    private func setupSearchObservers() {
        // Observe origin text changes
        $originText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if self?.activeField == .origin {
                    self?.searchAirports(query: searchText)
                }
            }
            .store(in: &cancellables)
        
        // Observe destination text changes
        $destinationText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if self?.activeField == .destination {
                    self?.searchAirports(query: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func setActiveField(_ field: SearchField) {
        activeField = field
        
        // Trigger search for current active field
        let currentText = field == .origin ? originText : destinationText
        if !currentText.isEmpty {
            searchAirports(query: currentText)
        } else {
            searchResults = []
        }
    }
    
    func selectAirport(_ airport: Airport) {
        switch activeField {
        case .origin:
            selectedOrigin = airport
            originText = airport.displayName
        case .destination:
            selectedDestination = airport
            destinationText = airport.displayName
        }
        
        // Clear search results after selection
        searchResults = []
    }
    
    func clearField(_ field: SearchField) {
        switch field {
        case .origin:
            originText = ""
            selectedOrigin = nil
        case .destination:
            destinationText = ""
            selectedDestination = nil
        }
        searchResults = []
    }
    
    func useCurrentLocation() {
        // TODO: Implement location services
        print("Use current location tapped")
    }
    
    func canCreateAlert() -> Bool {
        return selectedOrigin != nil && selectedDestination != nil
    }
    
    // MARK: - Search Method
    private func searchAirports(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        debugInfo = ""
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        searchTask = networkManager.requestAirports(query: trimmedQuery)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    switch completion {
                    case .failure(let error):
                        self?.handleSearchError(error)
                    case .finished:
                        print("✅ Search completed successfully")
                    }
                },
                receiveValue: { [weak self] airports in
                    print("📊 Received \(airports.count) airports")
                    self?.searchResults = airports
                    self?.debugInfo = "Found \(airports.count) results"
                }
            )
    }
    
    // MARK: - Error Handling
    private func handleSearchError(_ error: NetworkError) {
        print("❌ Search error: \(error.localizedDescription)")
        
        switch error {
        case .networkError(let underlyingError):
            if let urlError = underlyingError as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    errorMessage = "No internet connection. Please check your network."
                case .timedOut:
                    errorMessage = "Request timed out. Please try again."
                case .cannotFindHost, .cannotConnectToHost:
                    errorMessage = "Cannot connect to server. Please try again later."
                default:
                    errorMessage = "Network error: \(urlError.localizedDescription)"
                }
            } else {
                errorMessage = "Network connection error. Please check your internet connection."
            }
        case .decodingError:
            errorMessage = "Server response format error. This is likely a temporary issue."
            debugInfo = "Decoding failed - check console for raw response"
        case .invalidURL:
            errorMessage = "Invalid search request."
        default:
            errorMessage = "Search failed. Please try again."
        }
        
        searchResults = []
    }
    
    // MARK: - Sample Data for Testing
    func loadSampleData() {
        let sampleAirports = [
            Airport(iataCode: "JFK", icaoCode: "KJFK", name: "John F. Kennedy International Airport", cityName: "New York", countryName: "United States", countryCode: "US", latitude: 40.6413, longitude: -73.7781),
            Airport(iataCode: "LAX", icaoCode: "KLAX", name: "Los Angeles International Airport", cityName: "Los Angeles", countryName: "United States", countryCode: "US", latitude: 33.9425, longitude: -118.4081),
            Airport(iataCode: "LHR", icaoCode: "EGLL", name: "Heathrow Airport", cityName: "London", countryName: "United Kingdom", countryCode: "GB", latitude: 51.4700, longitude: -0.4543),
            Airport(iataCode: "CDG", icaoCode: "LFPG", name: "Charles de Gaulle Airport", cityName: "Paris", countryName: "France", countryCode: "FR", latitude: 49.0097, longitude: 2.5479),
            Airport(iataCode: "COK", icaoCode: "VOCI", name: "Cochin International Airport", cityName: "Kochi", countryName: "India", countryCode: "IN", latitude: 10.1520, longitude: 76.4019)
        ]
        
        let query = activeField == .origin ? originText : destinationText
        let filteredAirports = sampleAirports.filter { airport in
            query.isEmpty ||
            airport.cityName.lowercased().contains(query.lowercased()) ||
            airport.iataCode.lowercased().contains(query.lowercased()) ||
            airport.name.lowercased().contains(query.lowercased())
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchResults = filteredAirports
            self.isLoading = false
            self.debugInfo = "Using sample data (\(filteredAirports.count) results)"
        }
    }
}
