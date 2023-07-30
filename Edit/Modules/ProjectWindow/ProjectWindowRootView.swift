import SwiftUI

import WindowTreatment

struct ProjectWindowRootView<Content: View>: View {
	@Environment(WindowStateSynchronizationModel.self) private var syncModel
	@Environment(\.windowState) private var windowState

	let content: Content

	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		VStack {
			content
			Text("state: \(windowState.tabBarVisible ? "true" : "false")")
		}
		.onChange(of: windowState) { syncModel.windowStateChanged($0, $1) }
	}
}
