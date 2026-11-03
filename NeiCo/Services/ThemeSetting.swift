import SwiftUI
import Combine

/// Holds your two user-tweakable settings
/// and applies them to UIKit + SwiftUI appearances.
final class ThemeManager: ObservableObject {
  static let shared = ThemeManager()

  // Persisted across launches
  @AppStorage("isDarkMode") var isDarkMode = false {
    didSet { applyAppearance() }
  }

  @AppStorage("accentHex") var accentHex: String = "#00A86B" {
    didSet { applyAppearance() }
  }

  /// Computed SwiftUI Color from the stored hex
  var accentColor: Color {
    Color(UIColor(hex: accentHex) ?? .systemGreen)
  }

  private init() {
    applyAppearance()
  }

  private func applyAppearance() {
    // 1) Enforce global color-scheme
    UIApplication.shared.windows.first?.overrideUserInterfaceStyle =
      isDarkMode ? .dark : .light

    // 2) Configure your TabBar's background + tint
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = isDarkMode
      ? UIColor(white: 0.12, alpha: 1)
      : UIColor.systemBackground
    UITabBar.appearance().standardAppearance = tabBarAppearance
    if #available(iOS 15, *) {
      UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    UITabBar.appearance().tintColor = UIColor(accentColor)

    // 3) Any other UIKit tweaks you want…
  }
}

// MARK: • Helper to turn hex strings into UIColors
extension UIColor {
  convenience init?(hex: String) {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hex.hasPrefix("#") { hex.removeFirst() }
    guard hex.count == 6,
          let int = Int(hex, radix: 16)
    else { return nil }
    let r = CGFloat((int >> 16) & 0xFF)/255
    let g = CGFloat((int >> 8)  & 0xFF)/255
    let b = CGFloat( int        & 0xFF)/255
    self.init(red: r, green: g, blue: b, alpha: 1)
  }
}
