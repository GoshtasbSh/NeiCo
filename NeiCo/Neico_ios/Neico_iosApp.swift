//
//  Neico_iosApp.swift
//  Neico_ios
//
//  Created by Goshtasb Shahriari on 5/2/25.
//
import SwiftUI

@main
struct Neico_iosApp: App {
    // ① Put init() right here, inside the struct
    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        // Restore token on app launch
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            print("Restoring token on app launch: \(token)")
            APIClient.shared.authToken = token
        }
    }

    // any environment objects you need
    @StateObject private var basketVM = GroceryListViewModel()
    @StateObject private var theme = ThemeManager.shared
    @State private var isLoggedIn: Bool = false

    // ② Then your Scene
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
                    .environmentObject(theme)     // available everywhere
                    .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                    .tint(theme.accentColor)
                // apply the accent color everywhere
                
                
                .environmentObject(basketVM)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
                    .environmentObject(basketVM)
            }
        }
    }
}


