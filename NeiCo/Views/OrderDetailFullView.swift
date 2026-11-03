//
//  OrderDetailFullView.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/4/25.
//

// OrderDetailFullView.swift
import SwiftUI

/// Full-screen detail for an already-accepted order
/// (you already have the loaded OrderDetail in memory)
struct OrderDetailFullView: View {
    let detail: OrderDetail
    let onRemove: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // — store header —
                HStack(spacing: 12) {
                    Image(detail.storeIconName)
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text(detail.storeName)
                        .font(.title3).bold()
                    Spacer()
                }

                // — who placed the order —
                Text("Order by \(detail.userName)")
                    .font(.headline)

                // — list of items & prices —
                List(detail.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("Qty: \(item.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "$%.2f", item.price))
                    }
                }
                .listStyle(.insetGrouped)

                Spacer()

                // — remove (ignore) button —
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Label("Remove Order", systemImage: "trash.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Order Details")
            .toolbar {
                // top-left “Done” button same as your other detail
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onRemove() }
                }
            }
        }
    }
}
