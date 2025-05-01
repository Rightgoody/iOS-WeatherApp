//
//  WeatherCardView.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import SwiftUI

struct WeatherCardView: View {
    let weatherData: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                WeatherDetailView(icon: "thermometer",
                                value: "\(Int(weatherData.main.feels_like))°",
                                label: "Feels Like")
                Spacer()
                WeatherDetailView(icon: "humidity",
                                value: "\(weatherData.main.humidity)%",
                                label: "Humidity")
                Spacer()
                WeatherDetailView(icon: "wind",
                                value: "\(Int(weatherData.wind.speed)) km/h",
                                label: "Wind")
            }
            
            HStack {
                WeatherDetailView(icon: "sunrise",
                                value: Date(timeIntervalSince1970: weatherData.sys.sunrise).timeString(),
                                label: "Sunrise")
                Spacer()
                WeatherDetailView(icon: "sunset",
                                value: Date(timeIntervalSince1970: weatherData.sys.sunset).timeString(),
                                label: "Sunset")
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
    }
}

struct WeatherDetailView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
        }
        .foregroundColor(.white)
    }
}
