import SwiftUI

struct StoreGroceryListView: View {
    let store: Store
    @EnvironmentObject private var basketVM: GroceryListViewModel

    // Only the items for this store
    private var items: [Item] {
        basketVM.basket.filter { $0.store == store.id }
    }

    var body: some View {
        List {
            if items.isEmpty {
                Text("No items added from \(store.name).")
                    .foregroundColor(.gray)
            } else {
                ForEach(items) { item in
                    HStack {
                        if let image = item.image, let url = URL(string: "http://127.0.0.1:8000/static/\(image)") {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                        } else {
                            Image("placeholder")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(6)
                        }

                        Text(item.name)
                        Spacer()
                        Text(String(format: "$%.2f", item.price))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle(store.name)
    }

    private func deleteItems(at offsets: IndexSet) {
        // Map the offsets in the filtered `items` array to the actual Item values
        let toRemove = offsets.map { items[$0] }
        basketVM.remove(items: toRemove)
    }
}
