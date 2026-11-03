// OrdersView.swift

import SwiftUI
import MapKit

// MARK: — pill button for store filtering
struct FilterButton: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(minHeight: 32)
        }
        .background(isOn ? ThemeManager.shared.accentColor : Color.gray.opacity(0.2))
        .foregroundColor(isOn ? .white : .primary)
        .cornerRadius(8)
    }
}

// ——— shared cart icon using SF Symbols ——————————————————————————
struct SharedCartIcon: View {
    var body: some View {
        ZStack {
            Image(systemName: "cart.fill")
                .font(.system(size: 10))
            Image(systemName: "person.2.fill")
                .font(.system(size: 26))
                .offset(x: -8, y: -8)
        }
        .foregroundColor(.green)
        .frame(width: 36, height: 36)
    }
}

struct OrdersView: View {
    @StateObject private var vm = OrdersViewModel()
    @EnvironmentObject private var basketVM: GroceryListViewModel
    @State private var stores: [Store] = JSONService().load("stores_name")
    @State private var selectedPerson: PersonOrderLocation?
    // today's "price" multiplier (in future, bind to backend)
    @State private var priceFactor: Int = Int.random(in: 100...800)
    // pull-up sheet state
    @State private var sheetOffset: CGFloat = 0
    @State private var lastOffset:  CGFloat = 0

    // configuration
    private let maxRatio:      CGFloat = 0.6
    private let handleHeight:  CGFloat = 5
    private let handlePadding: CGFloat = 8
    private let tabBarHeight:  CGFloat = 49

    // basket sheet state
    @State private var showBasketSheet = false

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack(alignment: .topTrailing) {
                    mapSection
                    filterSection(geo: geo)
                    sheetSection(geo: geo)
                }
                // — tapped-pin detail sheet —
                .sheet(item: $selectedPerson) { person in
                    OrderDetailView(
                        orderID: person.id,
                        priceFactor: priceFactor,
                        onAccept: {
                            let detail: OrderDetail = JSONService().load("order_\(person.id)")
                            basketVM.appendOtherOrder(detail)
                            selectedPerson = nil
                        },
                        onIgnore: {
                            selectedPerson = nil
                        }
                    )
                }
                // — accepted-orders basket sheet —
                .sheet(isPresented: $showBasketSheet) {
                    acceptedOrdersSheet
                }
            }
            // put title inline and a tappable cart in the trailing nav-item
            .navigationBarTitle("Other Orders", displayMode: .inline)
            .navigationBarItems(trailing:
                Button {
                    showBasketSheet = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image("NeighborOrderBasket")              // ← your PNG in Assets.xcassets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)

                        if basketVM.otherOrders.count > 0 {
                            Text("\(basketVM.otherOrders.count)")
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 0, y: 0)
                        }
                    }
                }
            )
        }
    }
    // MARK: — map & filters (unchanged)

    private var mapSection: some View {
        Map(
            coordinateRegion: $vm.region,
            showsUserLocation: true,
            annotationItems: vm.sortedPeople
        ) { person in
            MapAnnotation(coordinate: person.coordinate) {
                VStack(spacing: 6) {
                    // 1️⃣ Your tappable "badge":
                    Button(action: { selectedPerson = person }) {
                        
                        HStack(spacing: 2) {
                            Text("\(person.ordersCount * priceFactor)")
                                .font(.caption2).bold()
                            Image("StarCoin")
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .padding(4)
                           .background(
                             // light: very light grouped grey; dark: slightly lighter than background
                             Color(.secondarySystemGroupedBackground)
                           )
                        .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.30), radius: 4, x: 0, y: 2)
                    }
                    .zIndex(1)

//                    // 2️⃣ The user pin below:
//                    Image(systemName: "person.crop.circle.fill")
//                        .font(.largeTitle)
//                        .foregroundColor(.blue)
                }
            }
        }
//        .opacity(0.6)
        .ignoresSafeArea(edges: [.top, .horizontal])
    }
    private func filterSection(geo: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterButton(
                        title: "All Stores",
                        isOn: vm.selectedStoreId == nil
                    ) { vm.selectedStoreId = nil }
                    ForEach(stores, id: \.id) { store in
                        FilterButton(
                            title: store.name,
                            isOn: vm.selectedStoreId == store.id
                        ) { vm.selectedStoreId = store.id }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, geo.safeAreaInsets.top - 60)
        .padding(.bottom, 12)
        .background(
               // this will be white in light mode, dark grey in dark mode
               Color(.systemGroupedBackground)
                 .edgesIgnoringSafeArea(.all)
             )
    }


    // MARK: — pull-up sheet with "card" style rows

    private func sheetSection(geo: GeometryProxy) -> some View {
        let fullH      = geo.size.height
        let safeBottom = geo.safeAreaInsets.bottom
        let expandedY  = fullH * (1 - maxRatio)
        let collapsedY = fullH
                       - handleHeight
                       - handlePadding
                       - safeBottom
                       - tabBarHeight
        let sheetH     = fullH * maxRatio + handleHeight + handlePadding

        return VStack(spacing: 0) {
            // handle bar
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: handleHeight)
                .padding(.top, handlePadding)

            // header
            HStack {
                Text("Current Orders")
                    .font(.title2).bold()
                Spacer()
                Menu {
                    ForEach(SortOption.allCases) { opt in
                        Button(opt.rawValue) { vm.sortOption = opt }
                    }
                } label: {
                    HStack {
                        Text("Sort by \(vm.sortOption.rawValue)")
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            // **step 2 fix**: filter before ForEach
            let filtered = { () -> [PersonOrderLocation] in
                guard let sid = vm.selectedStoreId else {
                    return vm.sortedPeople
                }
                return vm.sortedPeople.filter { $0.storeId == sid }
            }()

            List {
                ForEach(filtered) { person in
                  HStack(spacing: 12) {
                    // 1) Avatar
                    Image(systemName: "person.crop.circle.fill")
                      .resizable()
                      .frame(width: 40, height: 40)
                      .foregroundColor(.blue)

                    // 2) Name, items, cost & distance
                    VStack(alignment: .leading, spacing: 6) {
                      Text(person.userName)
                        .font(.headline)

                      Text("\(person.ordersCount) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                      // total cost + distance line
                      HStack {
                        // Total cost (placeholder calc)
                        let totalCost = Double(person.ordersCount) * 5.0
                        Text(String(format: "$%.2f total", totalCost))
                          .font(.subheadline)
                          .foregroundColor(.secondary)

                        Spacer()

                        
                      }
                    }

                    Spacer()

                    // 3) OrderCount+StarCoin & mile underneath
                    VStack(spacing: 4) {
                      HStack(spacing: 4) {
                          
                        Text("\(person.ordersCount * priceFactor)")
                          .font(.title).bold()
                        Image("StarCoin")
                          .resizable()
                          .frame(width: 30, height: 30)
                      }

                      // mile below the count
                      if let loc = vm.userLocation {
                        Text(String(format: "%.1f mi", person.distance(from: loc)))
                          .font(.subheadline)
                          .foregroundColor(.secondary)
                      }
                    }
                  }
                  .padding()
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(12)
                  .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                  .listRowSeparator(.hidden)
                  .listRowBackground(Color.clear)
                  .onTapGesture { selectedPerson = person }
                
                }
            }
            .listStyle(.plain)
            .frame(height: fullH * maxRatio)
        }
           .background(
             // light: very light grouped grey; dark: slightly lighter than background
            Color(.secondarySystemGroupedBackground)
           )
        .cornerRadius(12)
        .frame(height: sheetH)
        .offset(y: sheetOffset)
        .gesture(
            DragGesture()
                .onChanged { g in
                    let next = lastOffset + g.translation.height
                    sheetOffset = min(max(next, expandedY), collapsedY)
                }
                .onEnded { _ in
                    let mid = (expandedY + collapsedY) / 2
                    withAnimation {
                        sheetOffset = sheetOffset < mid ? expandedY : collapsedY
                    }
                    lastOffset = sheetOffset
                }
        )
        .onAppear {
            sheetOffset = fullH - 200
            lastOffset  = sheetOffset
        }
    }


    // inside OrdersView

    // MARK: — accepted orders sheet
    private var acceptedOrdersSheet: some View {
        // 1️⃣ Compute the filtered orders up‐front
        let filteredOrders: [OrderDetail] = {
            if let sid = vm.selectedStoreId {
                return basketVM.otherOrders.filter { order in
                    vm.sortedPeople
                      .first(where: { $0.userName == order.userName })?
                      .storeId == sid
                }
            } else {
                return basketVM.otherOrders
            }
        }()

        // 2️⃣ Return a NavigationView that simply composes two smaller pieces
        return NavigationView {
            VStack(spacing: 8) {
                acceptedFilterRow
                acceptedListView(filteredOrders: filteredOrders)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Accepted Orders")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showBasketSheet = false }
                }
            }
        }
    }

    // MARK: — smaller subview #1: the horizontal filter row
    private var acceptedFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(
                    title: "All Stores",
                    isOn: vm.selectedStoreId == nil
                ) { vm.selectedStoreId = nil }

                ForEach(stores, id: \.id) { store in
                    FilterButton(
                        title: store.name,
                        isOn: vm.selectedStoreId == store.id
                    ) {
                        vm.selectedStoreId = store.id
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }

    // MARK: — smaller subview #2: the list of accepted orders
    private func acceptedListView(filteredOrders: [OrderDetail]) -> some View {
        List {
            ForEach(filteredOrders) { order in
                // find matching person to get the ID back
                if let person = vm.sortedPeople.first(where: { $0.userName == order.userName }) {
                    NavigationLink {
                        OrderDetailView(
                            orderID: person.id,
                            priceFactor: priceFactor,
                            onAccept: { /* no-op for already accepted */ },
                            onIgnore: { basketVM.removeOtherOrder(id: order.id) }
                        )
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.blue)

                            Text(order.userName)
                                .font(.headline)

                            Spacer()

                            Text("\(person.ordersCount * priceFactor)")
                              .font(.title).bold()
                            Image("StarCoin")
                              .resizable()
                              .frame(width: 30, height: 30)
                        }
                        .padding()
                           .background(
                             // light: very light grouped grey; dark: slightly lighter than background
                             Color(.secondarySystemGroupedBackground)
                           )                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .onDelete { offsets in
                // Remove by matching indices in the master basketVM array
                offsets.forEach { i in
                    let id = filteredOrders[i].id
                    basketVM.removeOtherOrder(id: id)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: — basket button (unchanged)

    private func basketButton(geo: GeometryProxy) -> some View {
        Button { showBasketSheet = false } label: {
            ZStack(alignment: .topTrailing) {
                SharedCartIcon()
                if basketVM.otherOrders.count > 0 {
                    Text("\(basketVM.otherOrders.count)")
                        .font(.caption2).bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 12, y: -12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, geo.safeAreaInsets.top - 40)
        .padding(.trailing, 16)
    }
}
