import SwiftUI

struct HomeView: View {
  @StateObject private var homeVM = HomeViewModel()
  @EnvironmentObject private var basketVM: GroceryListViewModel
  @State private var searchText = ""

  private var filtered: [Store] {
    guard !searchText.isEmpty else { return homeVM.stores }
    return homeVM.stores.filter {
      $0.name.localizedCaseInsensitiveContains(searchText)
    }
  }

  var body: some View {
    NavigationView {
      ScrollView {
        StoreGridView(stores: filtered)
          .environmentObject(basketVM)
      }
      .navigationTitle("Stores")
      .navigationBarTitleDisplayMode(.inline)
      // ← Add the Home‐page basket button here
      .navigationBarItems(trailing:
        NavigationLink {
          GroceryListView()
            .environmentObject(basketVM)
        } label: {
          ZStack(alignment: .topTrailing) {
            Image(systemName: "cart.fill")
              .font(.title2)
            if basketVM.basket.count > 0 {
              Text("\(basketVM.basket.count)")
                .font(.caption2).bold()
                .foregroundColor(.white)
                .padding(4)
                .background(Color.red)
                .clipShape(Circle())
                .offset(x: 12, y: -8)
            }
          }
        }
      )
      .searchable(text: $searchText,
                  placement: .navigationBarDrawer(displayMode: .always))
    }
  }
}
