//
//  AddSurplusItemView.swift
//  NeiCo
//
//  Created by Goshtasb Shahriari on 5/20/25.
//

import SwiftUI
import PhotosUI

struct AddSurplusItemView: View {
  @Binding var isPresented: Bool
  let onSave: (MarketplaceItem) -> Void

  // MARK: – Form state
  @State private var name: String = ""
  @State private var selectedStore: String = ""
  @State private var quantity: Int = 0
  @State private var unitType: String = "Each"
  @State private var pricePerUnit: String = ""
  @State private var expiration: Date? = nil
  @State private var showDatePicker: Bool = false
  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var showPhotoPicker = false
  @State private var description: String = ""
  @State private var notes: String = ""
  @State private var showItemSuggestions = false

  // TODO: in future replace with your real store list & searchable backend
  private let storeOptions = ["Walmart", "Costco", "Sam's Club", "Publix"]
  private let unitOptions  = ["Each", "Pack", "Box"]
  private let itemOptions  = ["Bread", "Bananas", "Eggs", /*…*/]

  // only those that start with your input but aren't an exact match,
  // and with duplicates removed
  private var suggestions: [String] {
    guard showItemSuggestions, !name.isEmpty else { return [] }
    return itemOptions
      .filter {
        let lower = $0.lowercased()
        return lower.hasPrefix(name.lowercased())
            && lower != name.lowercased()      // drop exact match
      }
      .removingDuplicates()
  }

  var body: some View {
    VStack(spacing: 0) {
      // ── Header ──
      Text("Add Surplus")
        .font(.title)
        .bold()
        .padding(.top, 16)

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // ITEM DETAILS (store + name + suggestions)
          SectionHeader(title: "ITEM DETAILS")

            // STORE PICKER
            Menu {
              ForEach(storeOptions, id: \.self) { store in
                Button(store) {
                  selectedStore = store
                }
              }
            } label: {
              HStack {
                Text(selectedStore.isEmpty ? "Select Store" : selectedStore)
                  .foregroundColor(selectedStore.isEmpty ? .secondary : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                  .foregroundColor(ThemeManager.shared.accentColor)
              }
              .padding(.vertical, 12)
              .padding(.horizontal)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(ThemeManager.shared.accentColor, lineWidth: 1)
              )
            }
            .padding(.vertical, 4)
            
          // Name + suggestion dropdown
          ZStack(alignment: .topLeading) {
            TextField("Item Name", text: $name)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .onChange(of: name) { _ in
                showItemSuggestions = true
              }

            if showItemSuggestions && !suggestions.isEmpty {
              VStack(spacing: 0) {
                ForEach(suggestions, id: \.self) { suggestion in
                  Button(action: {
                    name = suggestion
                    showItemSuggestions = false
                  }) {
                    Text(suggestion)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.vertical, 8)
                      .background(Color(.systemGray6))
                  }
                  Divider()
                }
              }
              .background(Color(.systemBackground))
              .cornerRadius(8)
              .shadow(radius: 4, y: 2)
              .padding(.top, 44) // position below the TextField
            }
          }

          // AVAILABILITY
          SectionHeader(title: "AVAILABILITY")
          HStack(spacing: 16) {
            HStack {
              Button {
                if quantity > 0 { quantity -= 1 }
              } label: {
                Image(systemName: "minus")
                  .frame(width: 30, height: 30)
              }
              .background(Circle().fill(ThemeManager.shared.accentColor))
              .foregroundColor(.white)

              Text("\(quantity)")
                .frame(minWidth: 30)

              Button {
                quantity += 1
              } label: {
                Image(systemName: "plus")
                  .frame(width: 30, height: 30)
              }
              .background(Circle().fill(ThemeManager.shared.accentColor))
              .foregroundColor(.white)
            }

            Picker("", selection: $unitType) {
              ForEach(unitOptions, id: \.self) {
                Text($0)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
          }

          // PRICE PER UNIT
          TextField("Price per Unit", text: $pricePerUnit)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())

          // PPURCHASE DATE (optional)
          SectionHeader(title: "PURCHASE DATE")
          Button(action: { showDatePicker.toggle() }) {
            HStack {
              Text(
                expiration.map {
                  DateFormatter.localizedString(from: $0,
                                                dateStyle: .medium,
                                                timeStyle: .none)
                } ?? "Add purchase Date"
              )
              .foregroundColor(expiration == nil ? .secondary : .primary)
              Spacer()
              Image(systemName: "calendar")
                .foregroundColor(ThemeManager.shared.accentColor)
            }
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .stroke(ThemeManager.shared.accentColor, lineWidth: 1)
            )
          }

          if showDatePicker {
            DatePicker(
              "Purchase Date",
              selection: Binding<Date>(
                get: { expiration ?? Date() },
                set: { expiration = $0 }
              ),
              displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
          }

          // OPTIONAL PHOTO
          SectionHeader(title: "OPTIONAL PHOTO")
          Button(action: { showPhotoPicker = true }) {
            if let img = selectedImage {
              Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(8)
            } else {
              VStack {
                Image(systemName: "camera")
                  .font(.title2)
                Text("+ Add Photo")
              }
              .foregroundColor(ThemeManager.shared.accentColor)
              .frame(maxWidth: .infinity, minHeight: 120)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(ThemeManager.shared.accentColor.opacity(0.6),
                          style: StrokeStyle(lineWidth: 1, dash: [5]))
              )
            }
          }
          .sheet(isPresented: $showPhotoPicker) {
            PhotosPicker(
              selection: $selectedPhotoItem,
              matching: .images,
              photoLibrary: .shared()
            ) {
              EmptyView()
            }
            .onChange(of: selectedPhotoItem) { newItem in
              Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data)
                {
                  selectedImage = uiImage
                }
              }
            }
          }

          // DESCRIPTION
          Text("DESCRIPTION")
            .font(.headline)
            .foregroundColor(ThemeManager.shared.accentColor)
          TextEditor(text: $description)
            .frame(minHeight: 80)
            
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

          // NOTES
          Text("NOTES")
            .font(.headline)
            .foregroundColor(ThemeManager.shared.accentColor)
          TextEditor(text: $notes)
            .frame(minHeight: 60)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
      }

      // ── Buttons ──
      HStack(spacing: 12) {
        Button("Cancel") {
          isPresented = false
        }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)

        Button(action: saveAndDismiss) {
          Text("Save")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(ThemeManager.shared.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
      }
      .padding([.horizontal, .bottom], 16)
    }
    .background(Color(.systemBackground))
  }

  private func saveAndDismiss() {
    let new = MarketplaceItem(
      id: .init(),
      name: name,
      imageName: selectedImage != nil ? "userPhoto" : "placeholder",
      available: quantity,
      distance: 0,
      description: description
    )
    onSave(new)
    isPresented = false
  }
}

/// Reusable green-themed section header
private struct SectionHeader: View {
  let title: String
  var body: some View {
    Text(title)
      .font(.subheadline).bold()
      .foregroundColor(ThemeManager.shared.accentColor)
  }
}

// MARK: – Dedupe helper
extension Sequence where Element: Hashable {
  func removingDuplicates() -> [Element] {
    var seen = Set<Element>()
    return filter { seen.insert($0).inserted }
  }
}
