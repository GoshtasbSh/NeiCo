import SwiftUI


struct AccountView: View {
    // now driven by your real user model:
    @EnvironmentObject private var userVM: UserViewModel

    // baskets from the other pages:
    @EnvironmentObject private var groceryVM: GroceryListViewModel
    @EnvironmentObject private var marketplaceVM: MarketplaceViewModel

    // chat sheet state
    @State private var showChat = false
    @Binding var selectedTab: Tab
    
    // menu icons & titles
    private let menuItems: [(icon: String, title: String)] = [
        ("tray.full",    "My Orders"),
        ("person.2",     "My Shares"),
        ("heart",        "Favorites"),
        ("gearshape",    "Settings"),
        ("questionmark","Help")
    ]

    // Extracted: Surplus Added items
    private var surplusAddedItems: [AccountItem] {
        Dictionary(grouping: marketplaceVM.basket, by: \.id)
            .map { (id, items) in
                let first = items[0]
                return AccountItem(
                    id: String(describing: id),
                    imageName: first.imageName,
                    name: first.name,
                    quantity: items.count
                )
            }
    }

    // Extracted: Accepted Order Items
    var acceptedOrderItems: [AccountItem] {
        groceryVM.otherOrders.map { order in
            AccountItem(
                id: String(describing: order.id),
                imageName: order.storeIconName,
                name: order.userName,
                quantity: order.items.reduce(0) { $0 + $1.quantity }
            )
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // ─── Profile Header ───
                    HStack(spacing: 16) {
                        Group {
                            if !userVM.avatarImageName.isEmpty,
                               UIImage(named: userVM.avatarImageName) != nil
                            {
                                Image(userVM.avatarImageName)
                                    .resizable()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userVM.name)
                                .font(.title)
                                .bold()
                            
                            HStack(spacing: 4) {
                                Text("Credit: \(String(format: "%.1f", userVM.credit))")
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // ── Menu Grid ──
                    LazyVGrid(
                        columns: Array(repeating: .init(.flexible()), count: 5),
                        spacing: 16
                    ) {
                        ForEach(menuItems, id: \.title) { item in
                            MenuItemTile(item: item)
                        }
                    }
                    .padding(.horizontal)
                    NavigationLink(destination: GroceryListView()) {
                        Button { selectedTab = .home } label: {
                            AccountSectionView(
                                title: "Grocery List",
                                items: groceryVM.basket.map { item in
                                    AccountItem(
                                        id: String(describing: item.id),
                                        imageName: item.image ?? "placeholder",
                                        name: item.name,
                                        quantity: 1
                                    )
                                }
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    // ─── Grocery List ───
                    NavigationLink(destination: OrdersView()) {
                        Button { selectedTab = .orders } label: {
                            AccountSectionView(
                                title: "Other Orders accepted",
                                items: acceptedOrderItems
                            )
                        }
                    }
                    .buttonStyle(.plain)

                    // ─── Accepted Orders ───
                    
                    
                    // ─── Surplus Added ───
                    NavigationLink(destination: MarketplaceView()) {
                        Button { selectedTab = .marketplace } label: {
                            AccountSectionView(
                                title: "Surplus Added",
                                items: surplusAddedItems
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    // ─── Chat Button ───
                    
                    Button(action: { showChat = true }) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Chat with Neighbors")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showChat) {
                        
                        ChatView()
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Close") { showChat = false }
                                }
                            }
                        
                    }
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Account")
            
        }
    }
}

// MARK: — Data model for horizontal cards
struct AccountItem: Identifiable {
    let id: String
    let imageName: String
    let name: String
    let quantity: Int
}

// MARK: — MenuItemTile extracted for clarity
struct MenuItemTile: View {
    let item: (icon: String, title: String)
    var body: some View {
        let tile = VStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(.title2)
            Text(item.title)
                .font(.caption)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        if item.title == "Settings" {
            NavigationLink(destination: SettingsView()) {
                tile
            }
            .buttonStyle(.plain)
        } else {
            tile
        }
    }
}

// MARK: — Reusable section view
struct AccountSectionView: View {
  let title: String
  let items: [AccountItem]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.title2).bold()
        .padding(.horizontal)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(items) { item in
            NavigationLink {
              // ① Destination: your detail view for this item
              AccountItemDetailView(item: item)
            } label: {
              ZStack(alignment: .topTrailing) {
                // ② Your existing "card" content
                VStack(spacing: 4) {
                  if let url = URL(string: "http://127.0.0.1:8000/static/\(item.imageName)") {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                  } else {
                    Image("placeholder")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                  }
                  Text(item.name)
                    .font(.caption)
                    .lineLimit(1)
                }
                if item.quantity > 0 {
                  Text("\(item.quantity)")
                    .font(.caption2).bold()
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
                }
              }
            }
            .buttonStyle(.plain) // keeps the styling of the card
          }
        }
        .padding(.horizontal)
      }
    }
  }
}

// MARK: — Detail screen for a tapped card
struct AccountItemDetailView: View {
  let item: AccountItem

  var body: some View {
    VStack(spacing: 16) {
      if let url = URL(string: "http://127.0.0.1:8000/static/\(item.imageName)") {
        AsyncImage(url: url) { image in
            image.resizable()
        } placeholder: {
            Color.gray
        }
        .frame(height: 200)
        .cornerRadius(12)
      } else {
        Image("placeholder")
            .resizable()
            .frame(height: 200)
            .cornerRadius(12)
      }
      Text(item.name)
        .font(.largeTitle)
        .bold()
      Text("Quantity: \(item.quantity)")
        .font(.title3)
      Spacer()
    }
    .padding()
    .navigationTitle(item.name)
  }
}
