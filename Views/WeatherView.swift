//
//  WeatherView.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var weatherVM = WeatherViewModel()
    @StateObject private var locationVM = LocationViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            if weatherVM.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let weatherData = weatherVM.weatherData {
                ScrollView {
                    VStack(spacing: 20) {
                        WeatherHeaderView(weatherData: weatherData)
                        
                        WeatherCardView(weatherData: weatherData)
                        
                        if let forecastData = weatherVM.forecastData {
                            ForecastView(forecastData: forecastData)
                        }
                    }
                    .padding()
                }
            } else if let error = weatherVM.errorMessage {
                ErrorView(error: error, retryAction: fetchWeather)
            } else {
                LocationSearchView(locationVM: locationVM) { city in
                    weatherVM.fetchWeather(for: city)
                }
            }
        }
        .onAppear {
            if let location = locationVM.userLocation {
                weatherVM.fetchWeather(for: location)
            }
        }
    }
    
    private func fetchWeather() {
        if let location = locationVM.userLocation {
            weatherVM.fetchWeather(for: location)
        }
    }
}

struct WeatherHeaderView: View {
    let weatherData: WeatherData
    
    var body: some View {
        VStack {
            Text(weatherData.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let weather = weatherData.weather.first {
                Text(weather.main)
                    .font(.title2)
                Text(weather.description.capitalized)
                    .font(.subheadline)
            }
            
            Text("\(Int(weatherData.main.temp))°")
                .font(.system(size: 72, weight: .thin))
        }
        .foregroundColor(.white)
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error")
                .font(.title)
                .padding()
            Text(error)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .foregroundColor(.white)
    }
}
