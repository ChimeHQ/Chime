import SwiftUI

import WindowTreatment
import Search

struct ProjectWindowRoot<Content: View>: View {
	@Environment(WindowStateModel.self) private var model
	@Environment(\.windowState) private var windowState

	let content: Content

	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			content
			SearchBar()
		}
		.frame(minWidth: 100, minHeight: 100)
		.environment(\.theme, model.currentTheme)
		.environment(\.projectContext, model.projectContext)
		.environment(\.documentContext, model.documentContext)
		.ignoresSafeArea()
		.onChange(of: windowState) { model.windowStateChanged($0, $1) }
	}
}
