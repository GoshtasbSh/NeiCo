import SwiftUI

struct GroceryListView: View {
    @EnvironmentObject var basketVM: GroceryListViewModel
    @StateObject private var homeVM = HomeViewModel()
    @State private var mode: Mode = .all
    @State private var searchText = ""
    
    enum Mode: String, CaseIterable, Identifiable {
        case all = "All"
        case byStore = "By Store"
        var id: Self { self }
    }
    // only used in .all mode
     private var filteredBasket: [Item] {
         guard !searchText.isEmpty else { return basketVM.basket }
         return basketVM.basket.filter {
             $0.name.localizedCaseInsensitiveContains(searchText)
         }
     }

    var body: some View {
        print("GroceryListView showing \(basketVM.basket.count) items")
        return NavigationView {
            VStack {
                Picker("", selection: $mode) {
                    ForEach(Mode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                switch mode {
                case .all:
                    List {
                        ForEach(filteredBasket) { item in
                            HStack(spacing: 12) {
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

                                // ← Wrap name + store in a VStack
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    // look up the store name and style it like your price
                                    if let storeName = homeVM.stores.first(where: { $0.id == item.store })?.name {
                                        Text(storeName)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Text(String(format: "$%.2f", item.priceValue ?? 0.0))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search your list")
                    .id(basketVM.basket.map { $0.id }.joined())
                    .onAppear {
                        basketVM.loadBasket()
                    }
                    Section {
                        HStack {
                            Spacer()
                            Text("Total: \(String(format: "$%.2f", filteredBasket.reduce(0) { $0 + ( $1.priceValue ?? 0.0 ) }))")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }
                case .byStore:
                    List {
                        ForEach(homeVM.stores, id: \.id) { store in
                            NavigationLink(destination: StoreGroceryListView(store: store)) {
                                HStack {
                                    Text(store.name)
                                    Spacer()
                                    let count = basketVM.basket.filter { $0.store == store.id }.count
                                    if count > 0 {
                                        Text("\(count)")
                                            .font(.caption2).bold()
                                            .padding(6)
                                            .background(ThemeManager.shared.accentColor)
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            let storeItems = basketVM.basket.filter { $0.store == store.id }
                            let storeTotal = storeItems.reduce(0) { $0 + ( $1.priceValue ?? 0.0 ) }
                            if storeItems.count > 0 {
                                HStack {
                                    Spacer()
                                    Text("Store Total: \(String(format: "$%.2f", storeTotal))")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Grocery List")
            .toolbar { EditButton() }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { basketVM.basket[$0] }
        let group = DispatchGroup()
        for item in itemsToDelete {
            group.enter()
            basketVM.delete(item: item) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            basketVM.loadBasket()
        }
    }
}
