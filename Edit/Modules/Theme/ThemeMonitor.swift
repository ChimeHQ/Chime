import SwiftUI

struct ThemeMonitor<Content: View>: View {
	typealias ThemeUpdateHandler = (Theme, Theme.Context) -> Void

	@Environment(\.theme) private var theme
	@Environment(\.nsuiControlActiveState) private var controlActiveState
	@Environment(\.colorScheme) private var colorScheme
	let content: Content
	let themeUpdateAction: ThemeUpdateHandler

	init(_ content: () -> Content, themeUpdateAction: @escaping ThemeUpdateHandler) {
		self.content = content()
		self.themeUpdateAction = themeUpdateAction
	}

	private func themeUpdated() {
		themeUpdateAction(theme, context)
	}

	private var context: Theme.Context {
		.init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
	}

	var body: some View {
		content
		.onChange(of: theme) { _, _ in themeUpdated() }
		.onChange(of: colorScheme) { _, _ in themeUpdated() }
		.onChange(of: controlActiveState) { _, _ in themeUpdated() }
	}
}

struct ThemeMonitorModifier: ViewModifier {
	typealias ThemeUpdateHandler = (Theme, Theme.Context) -> Void

	let action: ThemeUpdateHandler

	init(_ action: @escaping ThemeUpdateHandler) {
		self.action = action
	}

	func body(content: Content) -> some View {
		ThemeMonitor({ content }, themeUpdateAction: action)
	}
}

extension View {
	public func onThemeChange(_ action: @escaping (Theme, Theme.Context) -> Void) -> some View {
		modifier(ThemeMonitorModifier(action))
	}
}

#Preview {
	ThemeMonitor({ Text("abc") }, themeUpdateAction: { _, _ in })
}
