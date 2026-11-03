//
//  StoreCellView.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import SwiftUI

struct StoreCellView: View {
  let store: Store
  let badgeCount: Int

  var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack(spacing: 8) {
        if let icon = store.icon, let url = URL(string: "http://127.0.0.1:8000/static/\(icon)") {
          AsyncImage(url: url) { image in
            image.resizable()
          } placeholder: {
            Color.gray
          }
          .frame(width: 40, height: 40)
          .clipShape(Circle())
        } else {
          Image("placeholder")
            .resizable()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        }

        Text(store.name)
          .font(.caption)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color(.systemGray6))
      .cornerRadius(10)

      if badgeCount > 0 {
        Text("\(badgeCount)")
          .font(.caption2).bold()
          .foregroundColor(.white)
          .padding(6)
          .background(ThemeManager.shared.accentColor)
          .clipShape(Circle())
          .offset(x: 8, y: -8)
      }
    }
  }
}
