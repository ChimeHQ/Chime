import SwiftUI

import ThemePark

struct ThemeMonitor<Content: View>: View {
	typealias ThemeUpdateHandler = (Theme, Query.Context) -> Void

	@Environment(\.theme) private var theme
	@Environment(\.styleQueryContext) private var context
	let content: Content
	let themeUpdateAction: ThemeUpdateHandler

	init(_ content: () -> Content, themeUpdateAction: @escaping ThemeUpdateHandler) {
		self.content = content()
		self.themeUpdateAction = themeUpdateAction
	}

	private func themeUpdated() {
		themeUpdateAction(theme, context)
	}

	var body: some View {
		content
			.themeSensitive()
			.onChange(of: theme.identity, initial: true) { _, _ in themeUpdated() }
	}
}

struct ThemeMonitorModifier: ViewModifier {
	typealias ThemeUpdateHandler = (Theme, Query.Context) -> Void

	let action: ThemeUpdateHandler

	init(_ action: @escaping ThemeUpdateHandler) {
		self.action = action
	}

	func body(content: Content) -> some View {
		ThemeMonitor({ content }, themeUpdateAction: action)
	}
}

extension View {
	public func onThemeChange(_ action: @escaping (Theme, Query.Context) -> Void) -> some View {
		modifier(ThemeMonitorModifier(action))
	}
}

#Preview {
	ThemeMonitor({ Text("abc") }, themeUpdateAction: { _, _ in })
}
