import SwiftUI

struct ForecastScreen: View {
    var body: some View {
        Text("Forecast Coming Soon")
            .font(.title)
            .navigationTitle("Forecast")
    }
}

#Preview {
    NavigationView {
        ForecastScreen()
    }
} 