import SwiftUI
import MapKit

struct MapScreen: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
        }
        .navigationTitle("Map")
    }
}

#Preview {
    NavigationView {
        MapScreen()
    }
} 
