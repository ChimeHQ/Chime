import SwiftUI

import DocumentContent
import Theme

struct CharacterSelectionItem: View {
	@Environment(\.documentCursors) private var cursors

	private var selection: [NSRange] {
		cursors.map({ $0.selection })
	}

	private var count: String {
		if selection.isEmpty {
			return "-"
		}

		let value = selection.reduce(0, { $0 + $1.length })

		if value == 0 {
			return "-"
		}

		return String(value)
	}

	private var span: String {
		guard let first = selection.first else {
			return "-"
		}

		let initial = (first.lowerBound, first.upperBound)

		let minMax: (Int, Int) = selection.dropFirst().reduce(initial) {
			let newMin = min($0.0, $1.lowerBound)
			let newMax = max($0.1, $1.upperBound)

			return (newMin, newMax)
		}

		if minMax.0 == minMax.1 {
			return String(minMax.0)
		}

		return "\(minMax.0)-\(minMax.1)"
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

	private var longestRepresentedSpan: String {
		"\(longestRepresentedCount)-\(longestRepresentedCount)"
	}

	var body: some View {
		LabelledSpanCount(
			"Character",
			spanPair: (span, longestRepresentedSpan),
			countPair: (count, longestRepresentedCount)
		)
	}
}

#Preview {
    CharacterSelectionItem()
}
