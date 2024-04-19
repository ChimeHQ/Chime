import SwiftUI

import DocumentContent
import Diagnostics
import TextSystem
import UIUtility

@MainActor
struct StatusBarContent: View {
	@Environment(\.documentCursors) private var cursors
	@Environment(\.textViewSystem) private var textViewSystem
	@Environment(EditorStateModel.self) private var editorModel
	@Environment(DiagnosticsModel.self) private var diagnosticsModel
	@State private var model = SelectionViewModel()

	private let padding = 8.0

	var body: some View {
		HStack(spacing: 0) {
			LineSelectionItem()
				.padding(.trailing, padding)

			CharacterSelectionItem()

			if diagnosticsModel.hasDiagnostics {
				DiagnosticsStatusBarItem(
					infoCount: diagnosticsModel.infoCount,
					warnCount: diagnosticsModel.warningCount,
					errorCount: diagnosticsModel.errorCount
				)
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
		.animation(.default, value: diagnosticsModel.hasDiagnostics)
//		.onChange(of: diagnosticsModel.hasDiagnostics, initial: true) {
//			withAnimation {
//				self.diagnosticsVisible = diagnosticsModel.hasDiagnostics
//			}
//		}
	}
}

#Preview {
    StatusBarContent()
}
