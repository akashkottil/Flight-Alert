import SwiftUI

// MARK: - Simple Debug View for API Testing
struct DebugAPIView: View {
    @StateObject private var viewModel = LocationSearchViewModel()
    @State private var testQuery = "new"
    @State private var showRawResponse = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Test input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug API Response:")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter search term", text: $testQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Test API") {
                            testAPI()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                    }
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                        Text("Testing API...")
                    }
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Error:")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Debug info
                if !viewModel.debugInfo.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debug Info:")
                            .font(.headline)
                        
                        Text(viewModel.debugInfo)
                            .font(.caption)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Results
                if !viewModel.searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Results (\(viewModel.searchResults.count)):")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.searchResults) { airport in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(airport.iataCode) - \(airport.displayName)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(airport.fullName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions:")
                        .font(.headline)
                    
                    Text("""
                    1. Enter a search term (e.g., "new", "london", "jfk")
                    2. Click 'Test API' to test the endpoint
                    3. Check the Xcode console for detailed logs
                    4. Results will show here if successful
                    """)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("API Debug")
        }
    }
    
    private func testAPI() {
        // Set the search field and trigger search
        viewModel.setActiveField(.origin)
        viewModel.originText = testQuery
        
        // The search will trigger automatically due to the text binding
        // But we can also trigger it manually for debugging
        print("🔍 Debug: Testing API with query '\(testQuery)'")
    }
}

#Preview {
    DebugAPIView()
}
