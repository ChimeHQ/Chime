import SwiftUI

import TextSystem
import Theme

/// Display the current line section.
///
/// Single line: "line:column", "-"
/// Multiple lines: "start-end", "count"
@MainActor
struct LineSelectionItem: View {
	@Environment(SelectionViewModel.self) private var model

	private var count: String {
		switch model.lineSelection {
		case .single:
			return "-"
		case let .multiple(start: start, end: end):
			let count = end - start + 1

			return String(count)
		}
	}

	private var span: String {
		switch model.lineSelection {
		case let .single(index: index, column: column):
			"\(index):\(column)"
		case let .multiple(start: start, end: end):
			"\(start)-\(end)"
		}
	}

	var body: some View {
		LabelledTwoPartItem(
			"Line",
			spanPair: (span, span),
			countPair: (count, count)
		)
	}
}

#Preview {
    LineSelectionItem()
}
