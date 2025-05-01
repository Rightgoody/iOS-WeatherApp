//
//  LocationService.swift
//  
//
//  Created by Joshua on 4/30/25.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func searchLocation(_ query: String, completion: @escaping (Result<[String], Error>) -> Void)
}

class LocationService: LocationServiceProtocol {
    private let geocoder = CLGeocoder()
    
    func searchLocation(_ query: String, completion: @escaping (Result<[String], Error>) -> Void) {
        geocoder.geocodeAddressString(query) { (placemarks, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let locations = placemarks?.compactMap { placemark in
                if let city = placemark.locality, let country = placemark.country {
                    return "\(city), \(country)"
                }
                return nil
            } ?? []
            
            completion(.success(locations))
        }
    }
}
