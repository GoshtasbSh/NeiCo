//
//  HomeViewModel.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation

class HomeViewModel: ObservableObject {
  @Published var stores: [Store] = []
  @Published var featured: [FeaturedStore] = []

  init() {
    loadStores()
  }

  func loadStores() {
    APIClient.shared.fetchStores { [weak self] stores in
      self?.stores = stores
      // Optionally, set featured stores here
      self?.featured = Array(stores.prefix(7)).map { store in
        FeaturedStore(
          store: store,
          discount: ["$5 off","$10 off","$15 off","$2 off","Save $3"].randomElement()!,
          eta: ["By 3:00pm","By 4:00pm","By 5:30pm"].randomElement()!,
          ordersCount: Int.random(in: 1...5)
        )
      }
    }
  }
}
