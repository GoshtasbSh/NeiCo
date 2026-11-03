//
//  UserViewModel.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/7/25.
//

import SwiftUI
import Combine

final class UserViewModel: ObservableObject {
    @Published var name: String        = "Your Name"
    @Published var avatarImageName: String = "placeholder_profile"
    @Published var credit: Double       = 0.0
}
