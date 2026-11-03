import SwiftUI

// MARK: — model for each chat contact
struct ChatContact: Identifiable {
  let id = UUID()
  let avatarName: String    // your asset name
  let name: String
  let isOrder: Bool         // whether to show cart icon vs person icon
}

// MARK: — the main chat list view
struct ChatView: View {
  @State private var selectedTab = 0
  @State private var searchText = ""

  // sample data; replace with your real data
  private let allContacts: [ChatContact] = [
    .init(avatarName: "alice", name: "Alice Smith",   isOrder: true),
    .init(avatarName: "bob",   name: "Bob Johnson",   isOrder: true),
    .init(avatarName: "carol", name: "Carol Lee",     isOrder: true),
    .init(avatarName: "jane",  name: "Jane Doe",      isOrder: false),
  ]

  private var filtered: [ChatContact] {
    let tabFiltered = allContacts.filter {
      selectedTab == 0 ? $0.isOrder : !$0.isOrder
    }
    guard !searchText.isEmpty else { return tabFiltered }
    return tabFiltered.filter {
      $0.name.localizedCaseInsensitiveContains(searchText)
    }
  }

  // ← Fetch the very last text bubble for that contact
  private func lastMessageText(for contact: ChatContact) -> String {
    ChatDetailView
      .sampleMessages(for: contact)
      .last?
      .text ?? ""
  }

    var body: some View {
    
            NavigationView {
              VStack(spacing: 0) {
                // ─── ORDERS / SHARED PICKER ───
                Picker("", selection: $selectedTab) {
                  Text("Orders").tag(0)
                  Text("Shared").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                

                // ─── CHAT LIST ───
                List(filtered) { contact in
                  NavigationLink(destination: ChatDetailView(contact: contact)) {
                    ChatRow(
                      contact: contact,
                      lastMessage: lastMessageText(for: contact)
                    )
                  }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchText, prompt: "Search")
              }
              .navigationTitle("Neighbors")
              .navigationBarTitleDisplayMode(.large)
            }
          }
    }


// MARK: — single row
struct ChatRow: View {
  let contact: ChatContact
  let lastMessage: String      // ← new

  var body: some View {
    HStack(spacing: 16) {
        // placeholder user icon for now
        Image(systemName: "person.crop.circle.fill")
        .resizable().scaledToFill()
        .frame(width: 48, height: 48)
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text(contact.name)
          .font(.headline)
        Text(lastMessage)    // ← shows the last bubble
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()

//      Image(systemName: contact.isOrder ? "cart" : "person.crop.circle")
//        .font(.title2)
//        .foregroundColor(.secondary)
    }
    .padding(.vertical, 8)
  }
}
