import SwiftUI

struct StoreGridView: View {
  let stores: [Store]
  @EnvironmentObject var basketVM: GroceryListViewModel

  private let columns = Array(
    repeating: GridItem(.flexible(), spacing: 16),
    count: 3
  )

  var body: some View {
    LazyVGrid(columns: columns, spacing: 16) {
      ForEach(stores, id: \.id) { store in
        // count how many items from this store are in the shared basket
        let count = basketVM.basket.filter { $0.store == store.id }.count

        NavigationLink(destination: StoreDetailView(store: store)
                        .environmentObject(basketVM)
        ) {
          StoreCellView(store: store, badgeCount: count)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal)
  }
}
