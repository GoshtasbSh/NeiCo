// CustomMapView.swift
import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let people: [PersonOrderLocation]
    let onTap: (PersonOrderLocation) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator

        // — Use the new iOS 15+ standard configuration —
        if #available(iOS 15.0, *) {
            let config = MKStandardMapConfiguration(elevationStyle: .flat)
            // hide all POI labels
            config.pointOfInterestFilter = .excludingAll
            // hide building extrusions
//            config.showsBuildings = false
            // you can also choose .mutedStandard for lighter color palette
            map.preferredConfiguration = config
        } else {
            // fallback on earlier versions
            map.mapType = .standard
            map.showsBuildings = false
            map.pointOfInterestFilter = .excludingAll   // available iOS 13+
        }

        map.setRegion(region, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.setRegion(region, animated: true)
        map.removeAnnotations(map.annotations)
//        map.addAnnotations(people.map(PersonOrderLocation.toAnnotation))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: CustomMapView
        init(_ parent: CustomMapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard
                let ann = view.annotation as? PersonOrderLocation.Annotation,
                let person = parent.people.first(where: { $0.id == ann.personID })
            else { return }
            parent.onTap(person)
        }
    }
}

// In your PersonOrderLocation model, add:
extension PersonOrderLocation {
    func toAnnotation() -> PersonOrderLocation.Annotation {
        .init(personID: id, coordinate: coordinate)
    }
    final class Annotation: NSObject, MKAnnotation {
        let personID: String
        var coordinate: CLLocationCoordinate2D
        init(personID: String, coordinate: CLLocationCoordinate2D) {
            self.personID = personID; self.coordinate = coordinate
            super.init()
        }
    }
}
