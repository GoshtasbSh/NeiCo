//
//  Store.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import Foundation

/// Represents a grocery store in the app.
struct Store: Identifiable, Codable {
    let id: String // or UUID, depending on your backend
    let name: String        // Store name (e.g., "Fresh Mart")
//    let subtitle: String    // Short description (e.g., "$ • Grocery • 12–22 min")
    let imageName: String?  // Optional name of an image asset in Assets.xcassets
    let icon: String?
}
