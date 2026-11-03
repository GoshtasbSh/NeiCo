import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var theme: ThemeManager

  var body: some View {
    Form {
      Toggle("Dark Mode", isOn: $theme.isDarkMode)

      ColorPicker("Accent Color", selection: Binding(
        get: { theme.accentColor },
        set: { new in
          // store as hex so AppStorage can persist
          theme.accentHex = new.toHex() ?? "#00A86B"
        })
      )
    }
    .navigationTitle("Settings")
  }
}

// Helper to extract hex from a SwiftUI Color
extension Color {
  func toHex() -> String? {
    guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
      return nil
    }
    let r = Int(components[0]*255)
    let g = Int(components[1]*255)
    let b = Int(components[2]*255)
    return String(format: "#%02X%02X%02X", r, g, b)
  }
}
