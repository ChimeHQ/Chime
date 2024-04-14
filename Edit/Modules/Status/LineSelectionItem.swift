import SwiftUI

import TextSystem
import Theme

@MainActor
struct LineSelectionItem: View {
	@Environment(\.documentCursors) private var cursors
	@Environment(\.textViewSystem) private var textViewSystem

	private var selection: [NSRange] {
		cursors.map({ $0.selection })
	}

	private var count: String {
		let set = IndexSet(ranges: selection)
		guard let span = textViewSystem?.textMetrics.lineSpan(for: set) else {
			return "-"
		}

		let delta = span.1.index - span.0.index + 1
		precondition(delta >= 0)

		return String(delta)
	}

	private var longestRepresentedCount: String {
		let maxValue = selection.last?.upperBound ?? 0

		// just defaulto this as a minimum size
		if maxValue < 99 {
			return "00"
		}

		let digits = Int(log10(Double(maxValue)) + 1)

		return String(repeating: "0", count: digits)
	}

	var body: some View {
		LabelledSpanCount(
			"Line",
			spanPair: ("0", "0"),
			countPair: (count, longestRepresentedCount)
		)
	}
}

#Preview {
    LineSelectionItem()
}
