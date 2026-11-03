//
//  SortOption.swift.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/4/25.
//

// SortOption.swift
import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case distance     = "Distance"
    case orderCount   = "Order Count"
    var id: Self { self }
}
