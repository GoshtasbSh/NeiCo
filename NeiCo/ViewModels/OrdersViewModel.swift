// OrdersViewModel.swift

import Foundation
import MapKit
import Combine

/// your existing SortOption and PersonOrderLocation types
/// — don’t duplicate them here; use the ones in your Models folder!

final class OrdersViewModel: ObservableObject {
    // MARK: — bindings for your OrdersView
        // start the region centered at 0,0—will snap to the real user location as soon as it's available
        @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var selectedStoreId: String?
    @Published var sortOption: SortOption = .distance
    
    /// the four “people + orders” you’ll show on the map/list
    @Published private(set) var people: [PersonOrderLocation] = []
    
    /// applies your distance / order-count sorting
    var sortedPeople: [PersonOrderLocation] {
        // 1) filter first
        let filtered = selectedStoreId.flatMap { sid in
              people.filter { $0.storeId == sid }
            } ?? people

        // 2) then sort *that* filtered array
        switch sortOption {
        case .distance:
            guard let loc = userLocation else { return filtered }
            return filtered.sorted { $0.distance(from: loc) < $1.distance(from: loc) }
        case .orderCount:
            return filtered.sorted { $0.ordersCount > $1.ordersCount }
        }
    }
    
    // MARK: — internals
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    /// your four JSON suffixes
    private let codes = ["1A2B", "3C4D", "5E6F", "6E1A"]
    
    /// 🔑 **Fix:** explicitly tell Swift this is an array of Store,
    /// so `JSONService().load(...)` can infer `T = [Store]`
    private let stores: [Store] = JSONService().load("stores_name")
    
    
    init() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()

            locationManager.publisher(for: \.location)
              .compactMap { $0?.coordinate }
              .first()
              .sink { [weak self] coord in
                guard let self = self else { return }

                // 1️⃣ store the raw user location
                self.userLocation = coord

                // 2️⃣ recenter the map on the user
                self.region = MKCoordinateRegion(
                  center: coord,
                  span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )

                // 3️⃣ load your annotations around that real location
                self.loadPeople(around: coord)
              }
              .store(in: &cancellables)
        }
    
    
    /// if you ever need to recalc your Map’s region
    func updateRegion() {
        // e.g. region = MKCoordinateRegion(…)
    }
    
    
    // MARK: — load your four PersonOrderLocation instances
    
    private func loadPeople(around center: CLLocationCoordinate2D) {
        var newPeople: [PersonOrderLocation] = []
        
        for (i, code) in codes.enumerated() {
            // a) load the matching JSON
            let detail: OrderDetail = JSONService().load("order_\(code)")
            
            // b) nudge each spot a bit so annotations don’t stack
            let maxDelta = 0.01
            let latOffset = Double.random(in: -maxDelta...maxDelta)
            let lonOffset = Double.random(in: -maxDelta...maxDelta)
            let coord = CLLocationCoordinate2D(
                latitude:  center.latitude  + latOffset,
                longitude: center.longitude + lonOffset
            )
            
            // c) find the matching store ID from your stores list
            let storeId = stores
              .first { $0.name == detail.storeName }?
              .id ?? ""
            
            // d) build the PersonOrderLocation with the exact 4-char code
            newPeople.append(
              PersonOrderLocation(
                id:          code,
                userName:    detail.userName,
                coordinate:  coord,
                ordersCount: detail.items.count,
                storeId:     storeId
              )
            )
        }
        
        DispatchQueue.main.async {
            self.people = newPeople
        }
    }
    
}
