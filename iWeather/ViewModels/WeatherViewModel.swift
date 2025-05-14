import Foundation
import CoreLocation
import SwiftUI

@MainActor
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published State
    @Published var weatherData: WeatherData?
    @Published var dailyForecasts: [DailyForecast] = []
    @Published var lastLocation: CLLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherServiceManager()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - Location Permission & Request
    
    func requestLocation() {
        errorMessage = nil
        
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Location services are disabled. Please enable Location Services in Settings."
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isLoading = true
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location permission denied. Please enable it in Settings to get weather for your location."
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                isLoading = true
                manager.requestLocation()
                
            case .denied, .restricted:
                errorMessage = "Location access was denied. Enable it in Settings to use this feature."
                
            default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // 1) Store for forecast screen
        Task { @MainActor in
            self.lastLocation = location
        }
        // 2) Fetch current weather
        Task {
            await fetchWeather(for: location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            if let clErr = error as? CLError, clErr.code == .denied {
                self.errorMessage = "Location permission denied. Please enable it in Settings."
            } else {
                self.errorMessage = "Failed to get location: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Fetch Current Weather
    
    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        do {
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            let city = placemark?.locality ?? "Unknown"
            weatherData = try await weatherService.fetchWeather(for: city)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchWeather(for city: String) async {
        isLoading = true
        do {
            weatherData = try await weatherService.fetchWeather(for: city)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Fetch 5‑Day Forecast
    
    func fetchForecast(for location: CLLocation) async {
        do {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            dailyForecasts = try await weatherService.fetchForecast(latitude: lat, longitude: lon)
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to retrieve forecast: \(error.localizedDescription)"
                self.dailyForecasts = []
            }
        }
    }
    
    func fetchForecast(for city: String) async {
        do {
            dailyForecasts = try await weatherService.fetchForecast(city: city)
        } catch {
            await MainActor.run {
                self.errorMessage = "Could not load forecast for \(city). \(error.localizedDescription)"
                self.dailyForecasts = []
            }
        }
    }
}
