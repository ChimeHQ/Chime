import SwiftUI

import WindowTreatment

struct ProjectWindowRootView<Content: View>: View {
	@State private var syncModel = WindowStateSynchronizationModel()
	@Environment(\.controlActiveState) private var controlActiveState

	let content: Content

	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		HStack {
			Text("This is")
			content
			Text("the root view")
		}
		.observeWindowTabBarState()
		.onChange(of: controlActiveState) { syncModel.controlActiveState = $1 }
	}
}
