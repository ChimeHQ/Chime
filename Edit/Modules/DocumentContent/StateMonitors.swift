import SwiftUI

struct DocumentContentMonitorModifier: ViewModifier {
	typealias Action = (DocumentContent) -> Void

	@Environment(\.documentContent) private var documentContent

	let action: Action

	init(_ action: @escaping Action) {
		self.action = action
	}

	func body(content: Content) -> some View {
		content
			.onChange(of: documentContent) { action($1) }
	}
}

extension View {
	public func onDocumentContentChange(_ action: @escaping (DocumentContent) -> Void) -> some View {
		modifier(DocumentContentMonitorModifier(action))
	}
}

struct DocumentSelectionMonitorModifier: ViewModifier {
	typealias Action = ([NSRange]) -> Void

	@Environment(\.documentSelection) private var selection

	let action: Action

	init(_ action: @escaping Action) {
		self.action = action
	}

	func body(content: Content) -> some View {
		content
			.onChange(of: selection) { action($1) }
	}
}

extension View {
	public func onDocumentSelectionChange(_ action: @escaping ([NSRange]) -> Void) -> some View {
		modifier(DocumentSelectionMonitorModifier(action))
	}
}
