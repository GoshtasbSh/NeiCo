import Foundation

class GroceryListViewModel: ObservableObject {
    // Your existing grocery‐basket items
    @Published var basket: [Item] = []

    func loadBasket() {
        APIClient.shared.fetchGroceryList { [weak self] items in
            print("Loaded basket from backend: \(items)")
            self?.basket = items
        }
    }

    func add(item: Item) {
        print("Attempting to add item: \(item)")
        APIClient.shared.addGroceryItem(item) { [weak self] success in
            DispatchQueue.main.async {
                print("Add item success: \(success)")
                if success {
                    self?.loadBasket()
                } else {
                    print("Failed to add item to backend")
                }
            }
        }
    }

    func remove(item: Item) {
        APIClient.shared.removeItemFromGroceryList(item.id) { [weak self] success in
            if success { self?.loadBasket() }
        }
    }

    func remove(items: [Item]) {
        basket.removeAll { element in
            items.contains { $0.id == element.id }
        }
    }

    func remove(atOffsets offsets: IndexSet) {
        basket.remove(atOffsets: offsets)
    }

    // MARK: — Other users' accepted orders
    @Published var otherOrders: [OrderDetail] = []

    /// Append a full OrderDetail into the "Other Orders" list
    func appendOtherOrder(_ order: OrderDetail) {
        otherOrders.append(order)
    }

    /// Remove an accepted order by its UUID
    func removeOtherOrder(id: UUID) {
        otherOrders.removeAll { $0.id == id }
    }
    
    func removeOtherOrders(atOffsets offsets: IndexSet) {
            otherOrders.remove(atOffsets: offsets)
        }

    func delete(item: Item, completion: @escaping (Bool) -> Void) {
        let id = item.id
        guard let url = URL(string: "\(APIClient.shared.baseURL)grocery-items/\(id)/") else { completion(false); return }
        let request = APIClient.shared.makeRequest(url: url, method: "DELETE")
        print("Loading basket...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("Basket response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            let success = (response as? HTTPURLResponse)?.statusCode == 204
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}
