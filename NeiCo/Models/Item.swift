//
//  Item.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation

struct Item: Codable, Identifiable {
    let id: String
    let store: String
    let name: String
    let quantity: Double
    let unit: String?
    let price: String
    let image: String?
    let created_at: String

    var priceValue: Double? { Double(price) }

    // Custom decoding to handle id as Int or String, quantity as Int or Double
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // id can be Int or String
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else if let stringId = try? container.decode(String.self, forKey: .id) {
            self.id = stringId
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "ID is not Int or String")
        }

        self.store = try container.decode(String.self, forKey: .store)
        self.name = try container.decode(String.self, forKey: .name)

        // quantity can be Int or Double
        if let doubleQuantity = try? container.decode(Double.self, forKey: .quantity) {
            self.quantity = doubleQuantity
        } else if let intQuantity = try? container.decode(Int.self, forKey: .quantity) {
            self.quantity = Double(intQuantity)
        } else {
            self.quantity = 1.0 // fallback
        }

        self.unit = try? container.decode(String.self, forKey: .unit)
        self.price = try container.decode(String.self, forKey: .price)
        self.image = try? container.decode(String.self, forKey: .image)
        self.created_at = try container.decode(String.self, forKey: .created_at)
    }

    init(
        id: String,
        store: String,
        name: String,
        quantity: Double,
        unit: String?,
        price: String,
        image: String?,
        created_at: String
    ) {
        self.id = id
        self.store = store
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.price = price
        self.image = image
        self.created_at = created_at
    }
}
