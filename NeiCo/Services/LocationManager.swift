//
//  LocationManager.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation
import CoreLocation

/// Simple manager to get the user’s current location
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
      _ manager: CLLocationManager,
      didUpdateLocations locations: [CLLocation]
    ) {
        location = locations.first
    }

    func locationManager(
      _ manager: CLLocationManager,
      didFailWithError error: Error
    ) {
        print("Location error:", error)
    }
}
