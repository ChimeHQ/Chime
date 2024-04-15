import SwiftUI

import Theme

@MainActor
struct LabelledTwoPartItem: View {
	@Environment(\.theme) private var theme
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.controlActiveState) private var controlActiveState

	let label: String
	let primaryPair: (String, String)
	let secondaryPair: (String, String)

	init(_ label: String, spanPair: (String, String), countPair: (String, String)) {
		self.label = label
		self.primaryPair = spanPair
		self.secondaryPair = countPair
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
					Text(primaryPair.0)
					Text(primaryPair.1)
						.hidden()
				}
			}
			StatusItem(style: .trailing) {
				ZStack {
					Text(secondaryPair.0)
					Text(secondaryPair.1)
						.hidden()
				}
			}
		}
		.font(Font(theme.font(for: .statusLabel, context: context)))
	}
}

#Preview {
	LabelledTwoPartItem("blah", spanPair: ("0", "0"), countPair: ("0", "0"))
}
