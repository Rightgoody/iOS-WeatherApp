import SwiftUI

struct ForecastScreen: View {
    let city: String
    @StateObject private var viewModel: ForecastViewModel
    
    init(city: String) {
        self.city = city
        self._viewModel = StateObject(wrappedValue: ForecastViewModel(city: city))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading forecast...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if !viewModel.forecast.isEmpty {
                List(viewModel.forecast) { entry in
                    HStack {
                        if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(entry.icon)@2x.png") {
                            AsyncImage(url: iconURL) { image in
                                image.resizable()
                                     .scaledToFit()
                                     .frame(width: 50, height: 50)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date.formatted(.dateTime.weekday()))
                                .font(.headline)
                            Text("\(Int(entry.temperature))°F")
                                .font(.title2)
                                .bold()
                            Text(entry.condition)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No forecast available.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("\(city) Forecast")
    }
}

#Preview {
    NavigationView {
        ForecastScreen(city: "London")
    }
} 