import Foundation

// MARK: - Airport Model with Flexible Decoding
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
    
    // Standard CodingKeys for encoding
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
    
    // Custom initializer to handle multiple possible JSON key formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        
        // Try different possible keys for IATA code
        if let iata = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("iata_code")) {
            self.iataCode = iata
        } else if let iata = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("iata")) {
            self.iataCode = iata
        } else if let iata = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("code")) {
            self.iataCode = iata
        } else if let iata = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("airport_code")) {
            self.iataCode = iata
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.iataCode,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "IATA code not found with any expected key"
                )
            )
        }
        
        // Try different possible keys for ICAO code
        self.icaoCode = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("icao_code")) ??
                       try container.decodeIfPresent(String.self, forKey: AnyCodingKey("icao"))
        
        // Try different possible keys for name
        self.name = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("name")) ??
                    try container.decodeIfPresent(String.self, forKey: AnyCodingKey("airport_name")) ??
                    try container.decodeIfPresent(String.self, forKey: AnyCodingKey("airportName")) ??
                    "Unknown Airport"
        
        // Try different possible keys for city name
        self.cityName = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("city_name")) ??
                        try container.decodeIfPresent(String.self, forKey: AnyCodingKey("city")) ??
                        try container.decodeIfPresent(String.self, forKey: AnyCodingKey("cityName")) ??
                        "Unknown City"
        
        // Try different possible keys for country name
        self.countryName = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("country_name")) ??
                           try container.decodeIfPresent(String.self, forKey: AnyCodingKey("country")) ??
                           try container.decodeIfPresent(String.self, forKey: AnyCodingKey("countryName")) ??
                           "Unknown Country"
        
        // Try different possible keys for country code
        self.countryCode = try container.decodeIfPresent(String.self, forKey: AnyCodingKey("country_code")) ??
                          try container.decodeIfPresent(String.self, forKey: AnyCodingKey("countryCode"))
        
        // Try different possible keys for latitude
        self.latitude = try container.decodeIfPresent(Double.self, forKey: AnyCodingKey("latitude")) ??
                       try container.decodeIfPresent(Double.self, forKey: AnyCodingKey("lat"))
        
        // Try different possible keys for longitude
        self.longitude = try container.decodeIfPresent(Double.self, forKey: AnyCodingKey("longitude")) ??
                        try container.decodeIfPresent(Double.self, forKey: AnyCodingKey("lng")) ??
                        try container.decodeIfPresent(Double.self, forKey: AnyCodingKey("lon"))
    }
    
    // Standard encoding using the defined CodingKeys
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iataCode, forKey: .iataCode)
        try container.encodeIfPresent(icaoCode, forKey: .icaoCode)
        try container.encode(name, forKey: .name)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(countryName, forKey: .countryName)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
    }
    
    // Direct initializer for creating Airport objects programmatically
    init(iataCode: String, icaoCode: String? = nil, name: String, cityName: String, countryName: String, countryCode: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.iataCode = iataCode
        self.icaoCode = icaoCode
        self.name = name
        self.cityName = cityName
        self.countryName = countryName
        self.countryCode = countryCode
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Computed Properties
    var displayName: String {
        return "\(cityName), \(countryName)"
    }
    
    var fullName: String {
        return name
    }
    
    // Equatable
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        return lhs.iataCode == rhs.iataCode
    }
}

// MARK: - Helper for Dynamic CodingKeys
struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
    
    init(_ key: String) {
        self.init(stringValue: key)
    }
}

// MARK: - Response Models for Different API Formats
struct AirportDataResponse: Codable {
    let data: [Airport]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct AirportResultsResponse: Codable {
    let results: [Airport]
    let count: Int?
    let next: String?
    let previous: String?
}

struct AirportWrapperResponse: Codable {
    let airports: [Airport]
    let pagination: Pagination?
}

struct Pagination: Codable {
    let total: Int?
    let page: Int?
    let limit: Int?
    let totalPages: Int?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case page
        case limit
        case totalPages = "total_pages"
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
