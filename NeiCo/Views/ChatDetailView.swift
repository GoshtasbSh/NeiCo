// ChatDetailView.swift
// NeiCo

import SwiftUI

// MARK: — Message model
struct ChatMessage: Identifiable {
  let id: UUID
  let text: String
  let isFromCurrentUser: Bool
  let timestamp: Date
}

// MARK: — Detail chat screen
struct ChatDetailView: View {
  let contact: ChatContact    // comes from ChatView.swift

  @Environment(\.dismiss) private var dismiss
  @State private var messages: [ChatMessage] = []
    init(contact: ChatContact) {
      self.contact = contact
      _messages = State(initialValue: Self.sampleMessages(for: contact))
    }

     static func sampleMessages(for c: ChatContact) -> [ChatMessage] {
      switch c.name {
      case "Alice Smith":
        return [
          .init(id: UUID(), text: "Hi Alice, is that loaf still there?",         isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-400)),
          .init(id: UUID(), text: "Yep—fresh this morning!",                     isFromCurrentUser: true,  timestamp: Date().addingTimeInterval(-360)),
          .init(id: UUID(), text: "Great, I’ll swing by in an hour.",           isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-300)),
        ]

      case "Bob Johnson":
        return [
          .init(id: UUID(), text: "Hey Bob—saw your two orders, thanks!",        isFromCurrentUser: true,  timestamp: Date().addingTimeInterval(-500)),
          .init(id: UUID(), text: "No problem, when’s a good pickup time?",     isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-450)),
          .init(id: UUID(), text: "How about tomorrow at 5 PM?",                isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-400)),
        ]

      case "Carol Lee":
        return [
          .init(id: UUID(), text: "Carol, your order’s ready for pickup.",      isFromCurrentUser: true,  timestamp: Date().addingTimeInterval(-600)),
          .init(id: UUID(), text: "Awesome—thanks so much!",                    isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-580)),
        ]

      case "Jane Doe":
        return [
          .init(id: UUID(), text: "Hi Jane, are you still sharing eggs?",        isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-700)),
          .init(id: UUID(), text: "Yes! I have 6 left—$2/each.",                isFromCurrentUser: true,  timestamp: Date().addingTimeInterval(-650)),
          .init(id: UUID(), text: "Perfect. I’ll come by later today.",        isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-600)),
        ]

      default:
        return []
      }
    }
  @State private var draftText: String = ""

  // your “paper” background image from assets
  private let backgroundImageName = "chatPaper"

  var body: some View {
    ZStack {
      // ─── PAPER BACKGROUND ───
        Color(UIColor.secondarySystemGroupedBackground)
            .ignoresSafeArea()

      VStack(spacing: 0) {
        // ─── CUSTOM NAV-BAR ───
        HStack(spacing: 12) {
          Button { dismiss() } label: {
            Image(systemName: "chevron.left")
              .font(.title2)
          }

          Spacer()

          // placeholder avatar for now
          Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(width: 36, height: 36)
            .foregroundColor(.secondary)

          Text(contact.name)
            .font(.headline)

          Spacer()

          Button { /* … */ } label: {
            Image(systemName: "ellipsis")
              .font(.title2)
          }
        }
        .padding(.horizontal)
        .padding(.top, 16)      // ↑ a bit of breathing room under the notch
        .padding(.bottom, 8)

        // ─── MESSAGES ───
        ScrollViewReader { scroll in
          ScrollView {
            VStack(spacing: 12) {
              ForEach(messages) { msg in
                messageRow(msg)
              }
            }
            .padding(.horizontal)
            .padding(.top, 8)
          }
          .onChange(of: messages.count) { _ in
            if let last = messages.last {
              withAnimation {
                scroll.scrollTo(last.id, anchor: .bottom)
              }
            }
          }
        }

        // ─── INPUT BAR ───
        HStack(spacing: 12) {
          Button { /* attach… */ } label: {
            Image(systemName: "plus.circle")
              .font(.title2)
          }

          // pill‐shaped text field
          TextField("Message", text: $draftText)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .clipShape(Capsule())

          Button {
            let new = ChatMessage(
              id: UUID(),
              text: draftText,
              isFromCurrentUser: true,
              timestamp: Date()
            )
            messages.append(new)
            draftText = ""
          } label: {
            Image(systemName: "paperplane.fill")
              .font(.title2)
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
      }
    }
    .navigationBarHidden(true)
  }

  // ─── SINGLE MESSAGE ROW ───
  @ViewBuilder
  private func messageRow(_ msg: ChatMessage) -> some View {
    HStack {
      if msg.isFromCurrentUser { Spacer() }

      VStack(alignment: msg.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
        Text(msg.text)
          .padding(12)
          .background(msg.isFromCurrentUser
                      ? Color.blue
                      : Color(.systemGray6))
          .foregroundColor(msg.isFromCurrentUser
                           ? .white
                           : .primary)
          .clipShape(RoundedRectangle(cornerRadius: 16))

        Text(msg.timestamp, style: .time)
          .font(.caption2)
          .foregroundColor(.secondary)
      }

      if !msg.isFromCurrentUser { Spacer() }
    }
    .id(msg.id)
  }
}
