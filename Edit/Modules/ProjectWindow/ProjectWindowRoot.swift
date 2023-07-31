import SwiftUI

import WindowTreatment
import Search

struct ProjectWindowRoot<Content: View>: View {
	@Environment(WindowStateSynchronizationModel.self) private var syncModel
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
		.ignoresSafeArea()
		.onChange(of: windowState) { syncModel.windowStateChanged($0, $1) }
	}
}
