import SwiftUI
import CoreLocation

/// Main view displaying current weather information
struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var manualCity = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading weather...")
                } else if let weather = viewModel.weatherData {
                    VStack(spacing: 10) {
                        Text(weather.city)
                            .font(.largeTitle)
                            .bold()
                        Text("\(Int(weather.temperature))°")
                            .font(.system(size: 64))
                        Text(weather.condition)
                            .font(.title2)
                        if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png") {
                            AsyncImage(url: iconURL) { image in
                                image.resizable()
                                     .scaledToFit()
                                     .frame(width: 80, height: 80)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                } else {
                    Text("No weather data yet.")
                        .foregroundColor(.gray)
                }

                // Use location button
                Button(action: {
                    viewModel.requestLocation()
                }) {
                    Label("Use My Location", systemImage: "location.circle.fill")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }

                // Manual city entry fallback
                HStack {
                    TextField("Enter a city", text: $manualCity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Search") {
                        Task {
                            await viewModel.fetchWeather(for: manualCity)
                        }
                    }
                }.padding(.horizontal)

                // Error message if any
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("iWeather")
        }
    }
}

#Preview {
    HomeView()
} 
