import SwiftUI

import DocumentContent
import Theme

@MainActor
struct CharacterSelectionItem: View {
	@Environment(SelectionViewModel.self) private var model

	private var count: String {
		String(model.characterRange.count)
	}

	private var span: String {
		let start = model.characterRange.lowerBound
		let end = model.characterRange.upperBound

		return "\(start)-\(end)"
	}

	private var longestRepresentedCount: String {
		let maxValue = model.characterRange.upperBound

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
		LabelledTwoPartItem(
			"Character",
			spanPair: (span, longestRepresentedSpan),
			countPair: (count, longestRepresentedCount)
		)
	}
}

#Preview {
    CharacterSelectionItem()
}
