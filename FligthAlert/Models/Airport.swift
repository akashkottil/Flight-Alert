//
//  Airport.swift
//  FligthAlert
//
//  Created by Akash Kottil on 28/06/25.
//


import Foundation

// MARK: - Airport Model
struct Airport: Codable, Identifiable, Equatable {
    let id = UUID()
    let iataCode: String
    let icaoCode: String?
    let name: String
    let cityName: String
    let countryName: String
    let countryCode: String?
    let latitude: Double?
    let longitude: Double?
    
    private enum CodingKeys: String, CodingKey {
        case iataCode = "iata_code"
        case icaoCode = "icao_code"
        case name
        case cityName = "city_name"
        case countryName = "country_name"
        case countryCode = "country_code"
        case latitude
        case longitude
    }
    
    // MARK: - Computed Properties
    var displayName: String {
        return "\(cityName), \(countryName)"
    }
    
    var fullName: String {
        return name
    }
    
    // MARK: - Equatable
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        return lhs.iataCode == rhs.iataCode
    }
}

// MARK: - API Response Models
struct AirportSearchResponse: Codable {
    let airports: [Airport]
    let total: Int?
    let page: Int?
    let limit: Int?
    
    private enum CodingKeys: String, CodingKey {
        case airports = "data"
        case total
        case page
        case limit
    }
}

// MARK: - Search Parameters
struct AirportSearchParameters {
    let query: String
    let limit: Int
    let page: Int
    
    func toDictionary() -> [String: Any] {
        return [
            "q": query,
            "limit": limit,
            "page": page
        ]
    }
}