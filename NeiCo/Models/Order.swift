//
//  Order.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation

/// A single placed order
struct Order: Identifiable, Codable {
    let id: UUID
    let storeName: String
    let items: [String]
    let total: Double
    let date: Date

    init(storeName: String, items: [String], total: Double) {
        self.id = UUID()
        self.storeName = storeName
        self.items = items
        self.total = total
        self.date = Date()
    }
}
