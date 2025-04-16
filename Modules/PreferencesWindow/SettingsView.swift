import SwiftUI

import ExtendableHost
import Theme

public struct SettingsView: View {
	private enum Tabs: Hashable {
		case extensions
		case theme
	}

	@State private var activeTab = Tabs.theme
	private let themeStore: ThemeStore

	public init(themeStore: ThemeStore) {
		self.themeStore = themeStore
	}

    public var body: some View {
		Group {
			switch activeTab {
			case .theme:
				ThemeView(store: themeStore)
			case .extensions:
				AppExtensionBrowserView()
			}
		}
		.frame(width: 406 * 16.0/9.0, height: 406)
		.toolbar {
			Button(action: { self.activeTab = .theme }, label: {
				Label("Theme", systemImage: "paintpalette")
			})
			Button(action: { self.activeTab = .extensions }, label: {
				Label("Extensions", systemImage: "puzzlepiece.extension")
			})
		}
    }
}

#Preview {
    SettingsView(themeStore: ThemeStore())
}
