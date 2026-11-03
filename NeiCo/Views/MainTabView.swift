//
//  MainTabView.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import SwiftUI
enum Tab {
  case home, orders, marketplace, account
}
struct MainTabView: View {
    @StateObject private var userVM         = UserViewModel()
    @EnvironmentObject var basketVM: GroceryListViewModel
    @StateObject private var marketplaceVM  = MarketplaceViewModel()

    /// ← NEW: which tab is active
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem { Label("Home",      systemImage: "house") }

            OrdersView()
                .tag(Tab.orders)
                .tabItem { Label("Orders",    systemImage: "bag") }

            MarketplaceView()
                .tag(Tab.marketplace)
                .tabItem { Label("Marketplace", systemImage: "cart") }

            /// PASS THE BINDING down so AccountView can switch tabs:
            AccountView(selectedTab: $selectedTab)
                .tag(Tab.account)
                .tabItem { Label("Account",   systemImage: "person.crop.circle") }
        }
        .accentColor(.green)
        .environmentObject(userVM)
        .environmentObject(marketplaceVM)
    }
}
