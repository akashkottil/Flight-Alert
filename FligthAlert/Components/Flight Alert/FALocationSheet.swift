import SwiftUI

struct FALocationSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = LocationSearchViewModel()
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar design
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
                Spacer()
                Text("From Where??")
                    .bold()
                    .font(.title2)
                Spacer()
                // Empty view for balance
                Color.clear.frame(width: 40, height: 40)
            }
            .padding()
            
            // Origin search field
            VStack(alignment: .leading, spacing: 4) {
                Text("From")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                
                HStack {
                    TextField("Origin City, Airport or place", text: $viewModel.originText)
                        .padding()
                        .onTapGesture {
                            viewModel.setActiveField(.origin)
                        }
                    
                    if !viewModel.originText.isEmpty {
                        Button(action: {
                            viewModel.clearField(.origin)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            viewModel.activeField == .origin && !viewModel.originText.isEmpty ?
                            Color("FABlue") : Color.gray.opacity(0.8),
                            lineWidth: 1
                        )
                )
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Destination search field
            VStack(alignment: .leading, spacing: 4) {
                Text("To")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                
                HStack {
                    TextField("Destination City, Airport or place", text: $viewModel.destinationText)
                        .padding()
                        .onTapGesture {
                            viewModel.setActiveField(.destination)
                        }
                    
                    if !viewModel.destinationText.isEmpty {
                        Button(action: {
                            viewModel.clearField(.destination)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            viewModel.activeField == .destination && !viewModel.destinationText.isEmpty ?
                            Color("FABlue") : Color.gray.opacity(0.8),
                            lineWidth: 1
                        )
                )
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Use current location button
            Button(action: {
                viewModel.useCurrentLocation()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color("FABlue"))
                    Text("Use Current Location")
                        .foregroundColor(Color("FABlue"))
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .padding(.vertical, 10)
            }
            
            // Divider
            Divider()
                .padding(.horizontal)
            
            // Loading indicator
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding()
            }
            
            // Search results list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.searchResults) { airport in
                        locationResultRow(airport: airport)
                    }
                    
                    // Show default airports if no search results and no active search
                    if viewModel.searchResults.isEmpty && !viewModel.isLoading &&
                       viewModel.originText.isEmpty && viewModel.destinationText.isEmpty {
                        defaultAirportsList()
                    }
                }
            }
            
            // Create Alert Button (if both airports selected)
            if viewModel.canCreateAlert() {
                VStack {
                    Divider()
                    
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("Create Alert")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("FABlue"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        }
        .background(Color.white)
        .alert("Alert Created", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your flight alert from \(viewModel.selectedOrigin?.iataCode ?? "") to \(viewModel.selectedDestination?.iataCode ?? "") has been created successfully!")
        }
    }
    
    @ViewBuilder
    private func locationResultRow(airport: Airport) -> some View {
        Button(action: {
            viewModel.selectAirport(airport)
        }) {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    // Airport code badge
                    Text(airport.iataCode)
                        .font(.system(size: 14, weight: .medium))
                        .padding(8)
                        .frame(width: 44, height: 44)
                        .background(Color("FABlue").opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Main location name
                        Text(airport.displayName)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        // Subtitle with airport name
                        Text(airport.fullName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Show checkmark if selected
                    if (viewModel.activeField == .origin && viewModel.selectedOrigin == airport) ||
                       (viewModel.activeField == .destination && viewModel.selectedDestination == airport) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("FABlue"))
                            .font(.system(size: 20))
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
            }
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func defaultAirportsList() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Popular Airports")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer()
            }
            
            // Sample popular airports (you can replace with actual popular airports)
            let popularAirports = [
                Airport(iataCode: "JFK", icaoCode: "KJFK", name: "John F. Kennedy International Airport", cityName: "New York", countryName: "United States", countryCode: "US", latitude: 40.6413, longitude: -73.7781),
                Airport(iataCode: "LAX", icaoCode: "KLAX", name: "Los Angeles International Airport", cityName: "Los Angeles", countryName: "United States", countryCode: "US", latitude: 33.9425, longitude: -118.4081),
                Airport(iataCode: "LHR", icaoCode: "EGLL", name: "Heathrow Airport", cityName: "London", countryName: "United Kingdom", countryCode: "GB", latitude: 51.4700, longitude: -0.4543),
                Airport(iataCode: "CDG", icaoCode: "LFPG", name: "Charles de Gaulle Airport", cityName: "Paris", countryName: "France", countryCode: "FR", latitude: 49.0097, longitude: 2.5479),
                Airport(iataCode: "COK", icaoCode: "VOCI", name: "Cochin International Airport", cityName: "Kochi", countryName: "India", countryCode: "IN", latitude: 10.1520, longitude: 76.4019)
            ]
            
            ForEach(popularAirports) { airport in
                locationResultRow(airport: airport)
            }
        }
    }
}

#Preview {
    FALocationSheet()
}
