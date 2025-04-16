import AppKit
import SwiftUI

import DocumentContent
import Status
import Theme
import ThemePark
import UIUtility

@MainActor
struct EditorContent<Content: View>: View {
	@Environment(EditorStateModel.self) private var model
	@Environment(\.theme) private var theme
	@Environment(\.styleQueryContext) private var context

	let content: Content

	init(_ content: () -> Content) {
		self.content = content()
	}

	private var backgroundColor: PlatformColor {
		theme.style(for: .init(key: .editor(.background), context: context)).color
	}

	// also does not explicitly ignore safe areas, which ensures the titlebar is respected
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			content
			if model.statusBarVisible {
				StatusBar()
					.transition(.move(edge: .bottom))
			}
		}
		.animation(.default, value: model.statusBarVisible)
		.themeSensitive()
		.background(Color(backgroundColor))
		.environment(\.documentCursors, model.cursors)
		.environment(\.editorVisibleRect, model.visibleFrame)
		.environment(\.statusBarPadding, model.contentInsets)
	}
}
