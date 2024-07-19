import SwiftUI

import DocumentContent
import Navigator
import WindowTreatment
import Search
import Status
import ThemePark
import Utility

struct ProjectWindowRoot<Content: View>: View {
	@Environment(WindowStateModel.self) private var model
	@Environment(\.windowState) private var windowState
	@AppStorage("CurrentTheme", store: UserDefaults.sharedSuite) private var themeId: String = ""

	let content: Content

	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			content
			if model.searchActive {
				SearchBar()
			}
		}
		.frame(minWidth: 450, minHeight: 300)
		.environment(\.theme, model.currentTheme)
		.environment(\.projectContext, model.projectContext)
		.environment(\.documentContext, model.documentContext)
		.environment(model.navigatorModel)
		.environment(model.diagnosticsModel)
		.themeSensitive()
		.ignoresSafeArea()
		.onChange(of: windowState) { model.windowStateChanged($0, $1) }
		.onChange(of: themeId, initial: true) { _, newId in model.loadTheme(with: newId) }
	}
}
