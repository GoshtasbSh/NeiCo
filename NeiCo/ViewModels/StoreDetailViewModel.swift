//
//  StoreDetailViewModel.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/28/25.
//

import Foundation

class StoreDetailViewModel: ObservableObject {
    @Published var items: [StoreItem] = []
    private let storeId: String

    init(storeId: String) {
        self.storeId = storeId
        print("StoreDetailViewModel initialized for storeId: \(storeId)")
        loadItems()
    }

    func loadItems() {
        print("Loading items for store \(storeId)")
        APIClient.shared.fetchStoreItems(for: storeId) { [weak self] items in
            print("Loaded items: \(items)")
            self?.items = items
        }
    }
}
