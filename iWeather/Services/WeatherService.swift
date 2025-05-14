import Foundation
import CoreLocation
import WeatherKit

// In WeatherServiceManager
struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable {
    let dt: TimeInterval       // Unix timestamp for the forecast time
    let main: MainInfo
    let weather: [Weather]     // reuse Weather struct (description, icon)
}

struct MainInfo: Codable {
    let temp: Double
    let temp_min: Double?
    let temp_max: Double?
}

// You can reuse Weather struct from before (description, icon).

class WeatherServiceManager {
    private let apiKey = "ea53bd41a55a7f295942ddeac5f42d3f"  // (Use your actual API key here)

    // Fetch weather by city name (manual entry)
    // Updated to handle coordinate-based requests
    private func fetchWeatherData(from urlString: String) async throws -> WeatherData {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(OpenWeatherResponse.self, from: data).toWeatherData()
    }

    func fetchWeather(for city: String) async throws -> WeatherData {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(query)&appid=\(apiKey)&units=imperial"
        return try await fetchWeatherData(from: urlString)
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
        return try await fetchWeatherData(from: urlString)
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> [DailyForecast] {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&units=imperial&appid=\(apiKey)"
        return try await fetchForecastData(from: urlString)
    }

    func fetchForecast(city: String) async throws -> [DailyForecast] {
        // Encode city name for URL
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(query)&units=imperial&appid=\(apiKey)"
        return try await fetchForecastData(from: urlString)
    }

    private func fetchForecastData(from urlString: String) async throws -> [DailyForecast] {
        // 1. Create URL and fetch data (similar to fetchWeatherData)
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse) // e.g., 404 city not found
        }

        // 2. Decode the JSON into ForecastResponse
        let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)

        // 3. Process the 3-hourly data into daily summaries
        let dailyForecasts = processDailyForecasts(from: forecastResponse.list)
        return dailyForecasts
    }

    private func processDailyForecasts(from items: [ForecastItem]) -> [DailyForecast] {
        // Group forecast items by date (day)
        var groupedByDay: [String: [ForecastItem]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // format to get date string (year-month-day)
        for item in items {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayKey = dateFormatter.string(from: date)  // e.g. "2025-05-13"
            groupedByDay[dayKey, default: []].append(item)
        }
        // For each day, compute an average or use min/max temperatures
        var result: [DailyForecast] = []
        for (dayKey, items) in groupedByDay {
            // Sort by time in case not already sorted
            let sorted = items.sorted(by: { $0.dt < $1.dt })
            guard let first = sorted.first else { continue }
            // Use the first item's date as the day representation
            let date = Date(timeIntervalSince1970: first.dt)
            // Compute min and max temp of that day
            let temps = sorted.map { $0.main.temp }
            let minTemp = temps.min() ?? first.main.temp
            let maxTemp = temps.max() ?? first.main.temp
            // Use the weather of the first item (e.g., morning) or perhaps midday:
            let middayIndex = sorted.count / 2
            let weatherDesc = sorted[middayIndex].weather.first?.description.capitalized ?? "N/A"
            let icon = sorted[middayIndex].weather.first?.icon ?? "01d"
            result.append(DailyForecast(date: date, minTemp: minTemp, maxTemp: maxTemp, condition: weatherDesc, icon: icon))
        }
        // Sort results by date
        result.sort(by: { $0.date < $1.date })
        // Optionally, limit to 5 days:
        if result.count > 5 {
            result = Array(result.prefix(5))
        }
        return result
    }
}

// Model for daily forecast
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let minTemp: Double
    let maxTemp: Double
    let condition: String
    let icon: String
}

//
///// Service responsible for fetching weather data from external APIs
//class WeatherServiceManager {
//    private let apiKey = "ea53bd41a55a7f295942ddeac5f42d3f"
//
//    // Fetch weather by city name (manual entry)
//    // Updated to handle coordinate-based requests
//    private func fetchWeatherData(from urlString: String) async throws -> WeatherData {
//        guard let url = URL(string: urlString) else {
//            throw URLError(.badURL)
//        }
//        
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw URLError(.cannotParseResponse)
//        }
//        
//        guard httpResponse.statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//        
//        return try JSONDecoder().decode(OpenWeatherResponse.self, from: data).toWeatherData()
//    }
//
//    func fetchWeather(for city: String) async throws -> WeatherData {
//        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(query)&appid=\(apiKey)&units=imperial"
//        return try await fetchWeatherData(from: urlString)
//    }
//
//    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
//        return try await fetchWeatherData(from: urlString)
//    }
//}
