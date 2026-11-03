//
//  StoreCarousalView.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/2/25.
//

import SwiftUI

struct StoreCarouselView: View {
  let items: [FeaturedStore]
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(items) { featured in
          VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(featured.store.imageName ?? "placeholder_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .background(Color(.systemGray6))
                .clipShape(Circle())

              // orders count badge
              if let count = featured.ordersCount {
                Text("\(count)")
                  .font(.caption2).bold()
                  .foregroundColor(.white)
                  .padding(6)
                  .background(ThemeManager.shared.accentColor)
                  .clipShape(Circle())
                  .offset(x: 6, y: -6)
              }
            }

            Text(featured.store.name)
              .font(.caption)
              .foregroundColor(.primary)

            HStack(spacing: 4) {
              if let disc = featured.discount {
                Text(disc)
                  .font(.caption2).bold()
                  .padding(.horizontal, 6)
                  .padding(.vertical, 2)
                  .background(Color.red.opacity(0.8))
                  .foregroundColor(.white)
                  .cornerRadius(4)
              }
              if let eta = featured.eta {
                Text(eta)
                  .font(.caption2)
                  .foregroundColor(.gray)
              }
            }
          }
          .padding(8)
          .background(Color(.systemBackground))
          .cornerRadius(12)
          .shadow(color: Color.black.opacity(0.05), radius: 4, x:0, y:2)
        }
      }
      .padding(.horizontal)
    }
  }
}
