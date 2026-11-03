//
//  Featured\Store.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation

/// Wraps a Store with extra UI info for the carousel
struct FeaturedStore: Identifiable {
    let id: String
    let store: Store
    let discount: String?  // e.g. "$15 off"
    let eta: String?       // e.g. "By 4:00pm"
    let ordersCount: Int?  // badge count
    
    init(store: Store,
         discount: String? = nil,
         eta: String? = nil,
         ordersCount: Int? = nil)
    {
        self.id = store.id
        self.store = store
        self.discount = discount
        self.eta = eta
        self.ordersCount = ordersCount
    }
}
