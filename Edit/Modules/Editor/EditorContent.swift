import AppKit
import SwiftUI

import Status
import Theme
import UIUtility

struct EditorContent<Content: View>: View {
	typealias ThemeUpdateHandler = (Theme, Theme.Context) -> Void

	@Environment(\.theme) private var theme
	@Environment(\.controlActiveState) private var controlActiveState
	@Environment(\.colorScheme) private var colorScheme
	let content: Content
	let themeUpdateAction: ThemeUpdateHandler
	var statusMargin = CGSize()

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

	private var padding: EdgeInsets {
		EdgeInsets(top: 0.0, leading: 0.0, bottom: statusMargin.height, trailing: statusMargin.width)
	}

	// also does not explicitly ignore safe areas, which ensures the titlebar is respected
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			content
			StatusBar()
				.padding(padding)
		}
		.background(Color(theme.color(for: .background, context: context)))
		.onChange(of: theme) { _, _ in themeUpdated() }
		.onChange(of: colorScheme) { _, _ in themeUpdated() }
		.onChange(of: controlActiveState) { _, _ in themeUpdated() }
	}
}
