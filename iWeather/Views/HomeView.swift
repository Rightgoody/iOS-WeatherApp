import SwiftUI

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

                Button(action: {
                    viewModel.requestLocation()
                }) {
                    Label("Use My Location", systemImage: "location.circle.fill")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }

                HStack {
                    TextField("Enter a city", text: $manualCity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Search") {
                        Task {
                            await viewModel.fetchWeather(for: manualCity)
                        }
                    }
                }
                .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
                
                HStack(spacing: 16) {
                    NavigationLink(destination: MapScreen()) {
                        Label("Map", systemImage: "map.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ForecastScreen(viewModel: viewModel)) {
                        Label("Forecast", systemImage: "calendar")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("iWeather")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
