import SwiftUI

struct DocumentContentMonitor<Content: View>: View {
	@Environment(\.documentContent) private var documentContent
	let content: Content
	let action: DocumentContentMonitorModifier.Action

	init(_ content: () -> Content, action: @escaping DocumentContentMonitorModifier.Action) {
		self.content = content()
		self.action = action
	}

	private func contentUpdated() {
		action(documentContent)
	}

	var body: some View {
		content
		.onChange(of: documentContent) { _, _ in contentUpdated() }
	}
}

struct DocumentContentMonitorModifier: ViewModifier {
	typealias Action = (DocumentContent) -> Void

	let action: Action

	init(_ action: @escaping Action) {
		self.action = action
	}

	func body(content: Content) -> some View {
		DocumentContentMonitor({ content }, action: action)
	}
}

extension View {
	public func onDocumentContentChange(_ action: @escaping (DocumentContent) -> Void) -> some View {
		modifier(DocumentContentMonitorModifier(action))
	}
}
