import SwiftUI
import CoreLocation
import PhotosUI
// MARK: — Models

struct MarketplaceItem: Identifiable {
    let id: UUID
    let name: String
    let imageName: String
    let available: Int
    let distance: Double
    let description: String
}

// MARK: — ViewModel

class MarketplaceViewModel: ObservableObject {
    @Published var items: [MarketplaceItem] = [
        .init(id: .init(), name: "Paper Towels", imageName: "paper_towel", available: 3, distance: 0.5, description: "A detail of the item such as it is frmo what stores and so on"),
        .init(id: .init(), name: "Laundry Detergent",   imageName: "detergent", available: 6, distance: 1.2,description: "A detail of the item such as it is frmo what stores and so on"),
        .init(id: .init(), name: "Granola Bar",      imageName: "granola_bar", available: 9, distance: 3.0,description: "A detail of the item such as it is frmo what stores and so on"),
    ]
    @Published var basket: [MarketplaceItem] = []

    func addToBasket(_ item: MarketplaceItem) {
        basket.append(item)
    }
}

// MARK: — MarketplaceView

struct MarketplaceView: View {
    // ← use the shared VM instead of creating a new one
    @EnvironmentObject private var vm: MarketplaceViewModel

    @State private var showingAddItem       = false
    @State private var searchText           = ""
    @State private var showMarketplaceBasket = false

    // for quantity-selection sheet
    @State private var pendingItem: MarketplaceItem?
    @State private var pendingQuantity      = 1
    @State private var showQuantitySheet    = false

    // filter logic
    private var filteredItems: [MarketplaceItem] {
        guard !searchText.isEmpty else { return vm.items }
        return vm.items.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // ─── Item List ───
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: MarketplaceDetailView(item: item)) {
                                MarketplaceRow(item: item) { changedItem, newQty in
                                    // replace any prior entries for this item
                                    vm.basket.removeAll { $0.id == changedItem.id }
                                    // add `newQty` copies
                                    for _ in 0..<newQty {
                                        vm.basket.append(changedItem)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                // ─── Search Bar ───
                .searchable(text: $searchText, prompt: "Search items")

                // ─── Floating “＋” button ───
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddItem = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(ThemeManager.shared.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.bottom, 24)
                        .padding(.trailing, 24)
                    }
                }
            }
            .navigationTitle("Marketplace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                  ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                      showMarketplaceBasket = true
                    } label: {
                      ZStack(alignment: .topTrailing) {
                          Image("SurplusBasket")              // ← your PNG in Assets.xcassets
                              .resizable()
                              .scaledToFit()
                              .frame(width: 60, height: 60)
                        if vm.basket.count > 0 {
                          Text("\(vm.basket.count)")
                            .font(.caption2).bold()
                            .foregroundColor(.white)
                            .padding(4)
                            .background(ThemeManager.shared.accentColor)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                        }
                      }
                    }
                  }
                }
            // sheet to add a custom surplus item
            .sheet(isPresented: $showingAddItem) {
                AddSurplusItemView(isPresented: $showingAddItem) { new in
                    vm.items.append(new)
                }
            }
            // sheet to pick quantity when you tap a row’s Add button
            .sheet(isPresented: $showQuantitySheet) {
                if let item = pendingItem {
                    VStack(spacing: 24) {
                        Text("How many \(item.name)?")
                            .font(.headline)

                        HStack(spacing: 32) {
                            Button {
                                if pendingQuantity > 1 { pendingQuantity -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.gray.opacity(0.7)))
                            }

                            Text("\(pendingQuantity)")
                                .font(.title)
                                .frame(minWidth: 40)

                            Button {
                                if pendingQuantity < item.available { pendingQuantity += 1 }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    
                                    .background(Circle().fill(ThemeManager.shared.accentColor))
                            }
                        }

                        HStack {
                            Button("Cancel") { showQuantitySheet = false }
                            Spacer()
                            Button("Add \(pendingQuantity)") {
                                // commit to basket
                                vm.basket.removeAll { $0.id == item.id }
                                for _ in 0..<pendingQuantity {
                                    vm.basket.append(item)
                                }
                                showQuantitySheet = false
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            // sheet to view the marketplace basket
            // … earlier in MarketplaceView …

            .sheet(isPresented: $showMarketplaceBasket) {
                NavigationView {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // group identical items and show one row per distinct item
                            let grouped = Dictionary(grouping: vm.basket, by: \.id)
                            ForEach(grouped.values.sorted { $0.first!.name < $1.first!.name }, id: \.first!.id) { itemsForID in
                                let item = itemsForID.first!
                                BasketRow(item: item, quantity: itemsForID.count)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Your Basket")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // “Done” button to dismiss
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showMarketplaceBasket = false
                            }
                        }
                    }
                }
            
            }
        }
    }
}

// MARK: — Row

struct MarketplaceRow: View {
    let item: MarketplaceItem
//    let onAdd: () -> Void
    let onQuantityChange: (MarketplaceItem, Int) -> Void
    @State private var quantity: Int = 0

    var body: some View {
        HStack(spacing: 16) {
            Image(item.imageName)
                .resizable().scaledToFill()
                .frame(width: 72, height: 72)
                .clipped().cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.headline)
                Text("\(item.available) available")
                    .font(.subheadline).foregroundColor(.secondary)
                Text(String(format: "%.1f mi away", item.distance))
                    .font(.subheadline).foregroundColor(.secondary)
            }

            Spacer()

            QuantitySelector(quantity: $quantity, max: item.available)
            .onChange(of: quantity) { newQty in
                                    onQuantityChange(item, newQty)
                                }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: — Detail

struct MarketplaceDetailView: View {
    let item: MarketplaceItem

    var body: some View {
        VStack(spacing: 16) {
            Image(item.imageName)
                .resizable().scaledToFit()
                .frame(height: 200).cornerRadius(12)

            Text(item.name).font(.largeTitle).bold()
            Text("\(item.available) available").font(.title3)
            Text(String(format: "%.1f miles away", item.distance))
                .font(.subheadline).foregroundColor(.secondary)
            Text(item.description)
                        .font(.body)
                        .padding(.top, 8)

            Spacer()
        }
        .padding()
        .navigationTitle("Item Detail")
    }
}

// MARK: — Add Surplus
struct QuantitySelector: View {
    @Binding var quantity: Int
    let max: Int

    var body: some View {
        HStack(spacing: 16) {
            Button {
                if quantity > 0 { quantity -= 1 }
            } label: {
                Text("–")
                    .font(.title2)
                    .frame(width: 10, height: 10)
            }

            Text("\(quantity)")
                .font(.body)
                .frame(minWidth: 20)

            Button {
                if quantity < max { quantity += 1 }
            } label: {
                Text("+")
                    .font(.title2)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color(UIColor.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
// 1) Add this after QuantitySelector (anywhere below):

// Replace your existing BasketRow with this:

struct BasketRow: View {
    let item: MarketplaceItem
    let quantity: Int

    var body: some View {
        HStack(spacing: 16) {
            // 1) Image
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipped()
                .cornerRadius(8)

            // 2) Name + distance only
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                Text(String(format: "%.1f mi away", item.distance))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 3) Quantity on the right
            Text("×\(quantity)")
                .font(.headline)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
//struct AddSurplusItemView: View {
//    @Binding var isPresented: Bool
//    @State private var name = ""
//    @State private var available = ""
//    @State private var distance = ""
//    @State private var description = ""
//    let onSave: (MarketplaceItem) -> Void
//
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Item Name", text: $name)
//                TextField("Available (e.g. 5)", text: $available)
//                    .keyboardType(.numberPad)
//                TextField("Distacne", text: $distance).keyboardType(.numberPad)
//                TextField("Description", text: $description)
//                
//            }
//            .navigationTitle("Add Surplus")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                                            guard
//                                                let avail = Int(available),
//                                                let dist  = Double(distance)
//                                            else { return }
//                                            let new = MarketplaceItem(
//                                                id: .init(),
//                                                name: name,
//                                                imageName: "placeholder",
//                                                available: avail,
//                                                distance: dist,
//                                               description: description      // ← new
//                                            )
//                                            onSave(new)
//                                            isPresented = false
//                                        }
//                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { isPresented = false }
//                }
//            }
//        }
//    }
//}
