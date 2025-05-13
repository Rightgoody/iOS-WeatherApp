import Foundation
import WeatherKit
import CoreLocation

// This struct wraps the important weather data we'll display in the app.
struct WeatherData: Identifiable {
    let id = UUID()
    let city: String
    let temperature: Double
    let condition: String
    let icon: String
}

// OpenWeatherMap API Response Models
struct OpenWeatherResponse: Codable {
    let name: String
    let main: MainWeather
    let weather: [Weather]
}

struct MainWeather: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
} 
