//
//  LocationSearchViewModel.swift
//  FligthAlert
//
//  Created by Akash Kottil on 28/06/25.
//


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
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    private let searchLimit = 10
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
    
    // MARK: - Private Methods
    private func searchAirports(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        
        let searchParams = AirportSearchParameters(
            query: query.trimmingCharacters(in: .whitespacesAndNewlines),
            limit: searchLimit,
            page: 1
        )
        
        searchTask = networkManager.request(
            endpoint: "v1/airports/",
            parameters: searchParams.toDictionary(),
            responseType: AirportSearchResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .failure(let error):
                    self?.handleSearchError(error)
                case .finished:
                    break
                }
            },
            receiveValue: { [weak self] response in
                self?.searchResults = response.airports
            }
        )
    }
    
    private func handleSearchError(_ error: NetworkError) {
        print("Search error: \(error.localizedDescription)")
        
        switch error {
        case .networkError:
            errorMessage = "Network connection error. Please check your internet connection."
        case .decodingError:
            errorMessage = "Unable to process search results."
        case .invalidURL:
            errorMessage = "Invalid search request."
        default:
            errorMessage = "Search failed. Please try again."
        }
        
        // Show default results or clear results
        searchResults = []
    }
}