import Foundation

struct StoreItem: Identifiable, Codable {
    let id: Int
    let store: String      // This is the store's UUID as a String
    let name: String
    let image: String?     // Filename or URL, can be nil
    let price: String
    let unit: String?

    var priceValue: Double? {
        Double(price)
    }
}
