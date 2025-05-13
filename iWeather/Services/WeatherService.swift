import Foundation
import CoreLocation

/// Service responsible for fetching weather data from external APIs
class WeatherServiceManager {
    private let apiKey = ""

    // Fetch weather by city name (manual entry)
    func fetchWeather(for city: String) async throws -> WeatherData {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(query)&appid=\(apiKey)&units=imperial"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)

        return WeatherData(
            city: decoded.name,
            temperature: decoded.main.temp,
            condition: decoded.weather.first?.description.capitalized ?? "N/A",
            icon: decoded.weather.first?.icon ?? "01d"
        )
    }
} 
