import SwiftUI

struct ProjectWindowRootView<Content: View>: View {
	@State var syncModel = WindowStateSynchronizationModel()

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
	}
}
