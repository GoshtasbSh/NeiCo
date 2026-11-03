import Foundation
import CoreLocation

/// Model for a “person’s order” annotation
struct PersonOrderLocation: Identifiable {
    /// now the 4-char code from your filename
    let id: String

    /// real user name from the JSON
    let userName: String

    /// map annotation
    let coordinate: CLLocationCoordinate2D

    /// number of items in their order
    let ordersCount: Int

    /// store name (so you can filter by store)
    let storeId: String
}

extension PersonOrderLocation {
    /// helper to sort by distance
    func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
        let a = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let b = CLLocation(latitude: other.latitude, longitude: other.longitude)
        let meters =  a.distance(from: b)
        return meters / 1609.344
    }
}
