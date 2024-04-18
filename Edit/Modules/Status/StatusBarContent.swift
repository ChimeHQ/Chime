import SwiftUI

import DocumentContent
import TextSystem
import UIUtility

@MainActor
struct StatusBarContent: View {
	@Environment(\.documentCursors) private var cursors
	@Environment(\.textViewSystem) private var textViewSystem
	@Environment(EditorStateModel.self) private var editorModel
	@State private var model = SelectionViewModel()

	private let padding = 8.0

	var body: some View {
		HStack(spacing: 0) {
			LineSelectionItem()
				.padding(.trailing, padding)

			CharacterSelectionItem()

			if editorModel.hasDiagnostics {
				DiagnosticsStatusBarItem(infoCount: 3, warnCount: 5, errorCount: 6)
					.modifier(BottomPushAndSlideEffect(visible: editorModel.hasDiagnostics))
					.padding(.leading, padding)
			}

			if editorModel.searchCount > 0 {
				SearchItem(count: editorModel.searchCount)
					.padding(.leading, padding)
					.transition(.move(edge: .trailing))
			}
		}
		.environment(model)
		.onChange(of: cursors) {
			model.cursorsChanged(cursors)
		}
		.onChange(of: textViewSystem, initial: true) {
			model.textViewSystem = textViewSystem
		}
	}
}

#Preview {
    StatusBarContent()
}
