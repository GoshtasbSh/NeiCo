//
//  DetailView.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

struct GroceryDetailView: View {
  let person: PersonOrderLocation

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Store ID")) {
          Text(person.storeId)
        }
        Section(header: Text("Orders (\(person.ordersCount))")) {
          // demo items — in a real app you’d fetch these
          ForEach(0..<person.ordersCount, id: \.self) { idx in
            Text("• Item #\(idx+1)")
          }
        }
      }
      .navigationTitle("Order Details")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Done") { /* sheet auto-dismissed */ }
        }
      }
    }
  }
}
