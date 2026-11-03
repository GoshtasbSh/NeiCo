import SwiftUI
import MapKit

struct MapOrdersView: View {
  /// this drives the map’s center/zoom
  @Binding var region: MKCoordinateRegion

  /// the annotations you want to show
  let people: [PersonOrderLocation]

  /// who did I tap?
  @Binding var selectedPerson: PersonOrderLocation?

  var body: some View {
    CustomMapView(
      region: $region,
      people: people
    ) { person in
      // store the tapped person
      selectedPerson = person
    }
    .edgesIgnoringSafeArea(.all)
    .onAppear {
      // if you still need to recenter on user when view appears:
      // your OrdersViewModel already publishes region for you,
      // so you don’t need a LocationManager here.
    }
  }
}
