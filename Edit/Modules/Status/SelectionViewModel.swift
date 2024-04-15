import SwiftUI

import DocumentContent
import TextSystem

@MainActor
@Observable
final class SelectionViewModel {
	enum LineSelection {
		case single(index: Int, column: Int)
		case multiple(start: Int, end: Int)
	}

	@ObservationIgnored
	var textViewSystem: TextViewSystem?

	var lineSelection: LineSelection = .single(index: 0, column: 0)

	func cursorsChanged(_ cursors: [Cursor]) {
		guard let cursor = cursors.first else { return }

		guard let span = textViewSystem?.textMetrics.lineSpan(for: cursor.selection) else {
			return
		}

		let delta = span.1.index - span.0.index
		precondition(delta >= 0)

		if delta == 0 {
			let column = cursor.selection.location - span.0.location

			self.lineSelection = .single(index: span.0.index, column: column)
		} else {
			self.lineSelection = .multiple(start: span.0.index, end: span.1.index)
		}
	}
}
