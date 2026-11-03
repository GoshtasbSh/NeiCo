import SwiftUI

struct StoreDetailView: View {
    let store: Store
    @StateObject private var viewModel: StoreDetailViewModel
    @EnvironmentObject var basketVM: GroceryListViewModel

    @State private var searchText = ""

    private var filteredItems: [StoreItem] {
        if searchText.isEmpty {
            return viewModel.items as [StoreItem]
        } else {
            return viewModel.items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            } as [StoreItem]
        }
    }

    init(store: Store) {
        self.store = store
        _viewModel = StateObject(wrappedValue: StoreDetailViewModel(storeId: store.id))
    }

    var body: some View {
        List {
            ForEach(filteredItems, id: \.id) { item in
                StoreItemRow(item: item, addAction: {
                    addToBasket(item: item)
                })
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: GroceryListView()
                ) {
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
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .onAppear {
            print("StoreDetailView appeared")
            viewModel.loadItems()
            print("StoreDetailView IDs: \(filteredItems.map { $0.id })")
            basketVM.loadBasket()
        }
    }

    private func addToBasket(item: StoreItem) {
        let unit = item.unit?.isEmpty == false ? item.unit! : "each"
        let groceryItem = Item(
            id: UUID().uuidString,
            store: item.store,
            name: item.name,
            quantity: 1,
            unit: unit,
            price: String(format: "%.2f", item.priceValue ?? 0.0),
            image: item.image,
            created_at: ""
        )
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(groceryItem) {
            print("POST body: \(String(data: data, encoding: .utf8) ?? "")")
        }
        basketVM.add(item: groceryItem)
    }
}

struct StoreItemRow: View {
    let item: StoreItem
    let addAction: () -> Void

    var body: some View {
        HStack {
            if let imageName = item.image, let url = URL(string: "http://127.0.0.1:8000/static/\(imageName)") {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 60)
                .cornerRadius(6)
            }
            VStack(alignment: .leading) {
                Text(item.name)
                Text(String(format: "$%.2f", item.priceValue ?? 0.0))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: addAction) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}
