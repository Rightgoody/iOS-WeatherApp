import SwiftUI
import CoreLocation

struct ForecastScreen: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        VStack {
            if viewModel.dailyForecasts.isEmpty {
                ProgressView("Loading forecast…")
                    .task {
                        if let loc = viewModel.lastLocation {
                            await viewModel.fetchForecast(for: loc)
                        } else if let city = viewModel.weatherData?.city, !city.isEmpty {
                            await viewModel.fetchForecast(for: city)
                        }
                    }
            } else {
                List(viewModel.dailyForecasts) { day in
                    HStack {
                        Text(day.date, style: .date)
                            .font(.headline)
                        Spacer()
                        if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(day.icon)@2x.png") {
                            AsyncImage(url: iconURL) { image in
                                image.resizable()
                                    .frame(width: 30, height: 30)
                            } placeholder: {
                                Image(systemName: "cloud")
                            }
                        }
                        Text("\(Int(day.maxTemp))° / \(Int(day.minTemp))°")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("5‑Day Forecast")
        .padding()
    }
}

struct ForecastScreen_Previews: PreviewProvider {
    static var previews: some View {
        // You can wrap this in a dummy ViewModel for preview
        ForecastScreen(viewModel: WeatherViewModel())
    }
}
