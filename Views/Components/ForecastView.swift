//
//  ForecastView.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import SwiftUI

struct ForecastView: View {
    let forecastData: ForecastData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("5-Day Forecast")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ForEach(forecastData.list.prefix(5)) { item in
                HStack {
                    Text(Date(timeIntervalSince1970: item.dt).dayOfWeek())
                        .frame(width: 100, alignment: .leading)
                    
                    if let weather = item.weather.first {
                        Image(systemName: weather.iconSystemName)
                            .frame(width: 30)
                    }
                    
                    Text("\(Int(item.main.temp_max))° / \(Int(item.main.temp_min))°")
                        .frame(width: 100, alignment: .leading)
                    
                    Text(item.weather.first?.description.capitalized ?? "")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
    }
}
