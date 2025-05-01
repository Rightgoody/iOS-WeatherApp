//
//  WeatherData.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import Foundation

struct WeatherData: Codable {
    let coord: Coordinates
    let weather: [WeatherCondition]
    let main: MainWeatherData
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: TimeInterval
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct WeatherCondition: Codable, Identifiable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherData: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let type: Int
    let id: Int
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct ForecastData: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable, Identifiable {
    let id = UUID()
    let dt: TimeInterval
    let main: MainWeatherData
    let weather: [WeatherCondition]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let dt_txt: String
    
    private enum CodingKeys: CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, dt_txt
    }
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
    let timezone: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
