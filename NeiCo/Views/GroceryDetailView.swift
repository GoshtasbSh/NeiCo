// Views/GroceryDetailView.swift
// Shows somebody else's order.

import SwiftUI
import MapKit       // only if you need a map in the detail

struct GroceryDetailView: View, Identifiable {
  // this gives SwiftUI a stable `.sheet(item:)` identity
  let id = UUID()

  /// The person whose orders we’re inspecting
  let person: PersonOrderLocation

  /// Dismiss the sheet
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Store")) {
          // In a real app you'd look up the store name by `person.storeId`
          Text(person.storeId)
        }

        Section(header: Text("Orders (\(person.ordersCount))")) {
          // placeholder demo items; in a real app you’d fetch these
          ForEach(1...person.ordersCount, id: \.self) { idx in
            Text("• Item #\(idx)")
          }
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Order Details")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
  }
}
