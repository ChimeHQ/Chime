import SwiftUI

struct DocumentCursorsMonitorModifier: ViewModifier {
	typealias Action = ([Cursor]) -> Void

	@Environment(\.documentCursors) private var cursors

	let action: Action

	init(_ action: @escaping Action) {
		self.action = action
	}

	func body(content: Content) -> some View {
		content
			.onChange(of: cursors) { action($1) }
	}
}

extension View {
	/// Observe changes to the current selection within the open document.
	public func onDocumentCursorsChange(_ action: @escaping ([Cursor]) -> Void) -> some View {
		modifier(DocumentCursorsMonitorModifier(action))
	}
}
