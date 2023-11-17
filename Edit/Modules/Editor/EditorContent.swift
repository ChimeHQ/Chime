import AppKit
import SwiftUI

import DocumentContent
import Status
import Theme
import UIUtility

struct EditorContent<Content: View>: View {
	@Environment(DocumentStateModel.self) private var model
	@Environment(\.theme) private var theme
	@Environment(\.controlActiveState) private var controlActiveState
	@Environment(\.colorScheme) private var colorScheme
	let content: Content

	init(_ content: () -> Content) {
		self.content = content()
	}

	private var context: Theme.Context {
		.init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
	}

	// also does not explicitly ignore safe areas, which ensures the titlebar is respected
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			content
			StatusBar()
		}
		.background(Color(theme.color(for: .background, context: context)))
		.environment(\.documentSelection, model.selectedRanges)
		.environment(\.documentContent, model.documentContent)
	}
}
