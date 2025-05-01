//
//  WeatherViewModel.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import Foundation
import CoreLocation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var forecastData: ForecastData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        errorMessage = nil
        
        weatherService.fetchCurrentWeather(latitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] weatherData in
                self?.weatherData = weatherData
                self?.fetchForecast(for: location)
            }
            .store(in: &cancellables)
    }
    
    func fetchWeather(for city: String) {
        isLoading = true
        errorMessage = nil
        
        weatherService.fetchWeather(for: city)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] weatherData in
                self?.weatherData = weatherData
                let location = CLLocation(latitude: weatherData.coord.lat,
                                          longitude: weatherData.coord.lon)
                self?.fetchForecast(for: location)
            }
            .store(in: &cancellables)
    }
    
    private func fetchForecast(for location: CLLocation) {
        weatherService.fetchForecast(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] forecastData in
                self?.forecastData = forecastData
            }
            .store(in: &cancellables)
    }
}
