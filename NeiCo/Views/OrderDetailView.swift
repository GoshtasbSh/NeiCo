import SwiftUI

/// Data model matches your JSON
struct OrderDetail: Decodable, Identifiable {
    struct Item: Decodable, Identifiable {
        let id: String
        let name: String
        let quantity: Int
        let price: Double
    }

    let id: UUID = .init()
    let storeName: String
    let storeIconName: String
    let userName: String
    let items: [Item]
}

struct OrderDetailView: View {
    let orderID: String
    let priceFactor: Int
    let onAccept: () -> Void
    let onIgnore: () -> Void

    @State private var detail: OrderDetail?

    var body: some View {
        NavigationStack {
            Group {
                if let detail {
                    VStack(spacing: 16) {
                        // ── Header ──
                        HStack(spacing: 12) {
                            Image(detail.storeIconName)
                                .resizable()
                                .frame(width: 60, height: 60)
                            Text(detail.storeName)
                                .font(.title3).bold()
                            Spacer()
                        }

                        Text("Order by \(detail.userName)")
                            .font(.body)

                        // ── Items / Total / Reward Card ──
                    ScrollView {
                        VStack(spacing: 0) {
                            // 1) Each line item
                            ForEach(detail.items) { item in
                                VStack(spacing: 4) {
                                    
                                       HStack(spacing: 12) {
                                         // ← YOUR ITEM IMAGE (you can replace "placeholder"
                                         //    with whatever key you load from your JSON)
                                           Image(systemName: "photo")               // or Image(item.id) or your new imageName field
                                           .resizable()
                                           .frame(width: 48, height: 48)
                                           .cornerRadius(8)
                                    
                                         // the existing name & qty
                                         VStack(alignment: .leading, spacing: 4) {
                                           Text(item.name)
                                           Text("Qty: \(item.quantity)")
                                             .font(.caption)
                                             .foregroundColor(.secondary)
                                         }
                                    
                                         Spacer()
                                    
                                         // the existing price
                                         Text(String(format: "$%.2f", item.price))
                                       }
                                }
                                .padding()
                                Divider()
                                    .padding(.leading)
                            }

                            // 2) Total row
                            let total = detail.items
                                .reduce(0) { $0 + $1.price * Double($1.quantity) }
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Total")
                                        .font(.body)
                                    Spacer()
                                    Text(String(format: "$%.2f", total))
                                        .font(.body)
                                }
                                .padding()
                                Divider()
                                    .padding(.leading)
                            }

                            // 3) Reward row
                            let reward = detail.items.count * priceFactor
                            VStack {
                                HStack {
                                    Text("Reward")
                                        .font(.body)
                                    Spacer()
                                    Image("StarCoin")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("\(reward)")
                                        .font(.body)
                                }
                                .padding()
                            }
                           } // end VStack
                        } // end ScrollView
                        .frame(maxHeight: 500)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)

                        Spacer()

                        // ── Buttons ──
                        HStack(spacing: 16) {
                            Button { onIgnore() } label: {
                                Text("Ignore")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red, lineWidth: 1)
                                    )
                            }
                            Button { onAccept() } label: {
                                HStack {
                                    Text("\(detail.items.count * priceFactor)").bold()
                                    Image("StarCoin")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("Accept").bold()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ThemeManager.shared.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, safeAreaBottom + 8)
                    }
                    .padding()
                } else {
                    ProgressView("Loading…")
                }
            }
            .navigationTitle("Order Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onIgnore() }
                }
            }
        }
        .onAppear {
            detail = JSONService().load("order_\(orderID)")
        }
    }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
