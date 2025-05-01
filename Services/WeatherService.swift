//
//  WeatherService.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import Foundation
import Combine

protocol WeatherServiceProtocol {
    func fetchCurrentWeather(latitude: Double, longitude: Double) -> AnyPublisher<WeatherData, Error>
    func fetchWeather(for city: String) -> AnyPublisher<WeatherData, Error>
    func fetchForecast(latitude: Double, longitude: Double) -> AnyPublisher<ForecastData, Error>
}

class WeatherService: WeatherServiceProtocol {
    private let apiClient: APIClient
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = Constants.weatherAPIKey
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchCurrentWeather(latitude: Double, longitude: Double) -> AnyPublisher<WeatherData, Error> {
        let endpoint = "\(baseURL)/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        return apiClient.get(url: endpoint)
    }
    
    func fetchWeather(for city: String) -> AnyPublisher<WeatherData, Error> {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let endpoint = "\(baseURL)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        return apiClient.get(url: endpoint)
    }
    
    func fetchForecast(latitude: Double, longitude: Double) -> AnyPublisher<ForecastData, Error> {
        let endpoint = "\(baseURL)/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        return apiClient.get(url: endpoint)
    }
}
