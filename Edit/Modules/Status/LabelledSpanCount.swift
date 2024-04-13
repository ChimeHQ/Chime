import SwiftUI

import Theme

@MainActor
struct LabelledSpanCount: View {
	@Environment(\.theme) private var theme
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.controlActiveState) private var controlActiveState

	let label: String
	let spanPair: (String, String)
	let countPair: (String, String)

	init(_ label: String, spanPair: (String, String), countPair: (String, String)) {
		self.label = label
		self.spanPair = spanPair
		self.countPair = countPair
	}

	private var context: Theme.Context {
		.init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
	}

	var body: some View {
		HStack(spacing: 1.0) {
			StatusItem(style: .leading) {
				Text(label)
			}
			StatusItem(style: .middle) {
				ZStack {
					Text(spanPair.0)
					Text(spanPair.1)
						.hidden()
				}
			}
			StatusItem(style: .trailing) {
				ZStack {
					Text(countPair.0)
					Text(countPair.1)
						.hidden()
				}
			}
		}
		.font(Font(theme.font(for: .statusLabel, context: context)))
	}
}

#Preview {
	LabelledSpanCount("blah", spanPair: ("0", "0"), countPair: ("0", "0"))
}
