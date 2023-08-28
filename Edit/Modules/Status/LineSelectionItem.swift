import SwiftUI

import Theme

struct LineSelectionItem: View {
	@Environment(\.theme) private var theme
	@Environment(\.controlActiveState) private var controlActiveState
	@Environment(\.colorScheme) private var colorScheme

	private var context: Theme.Context {
		.init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
	}

	var body: some View {
		HStack(spacing: 1.0) {
			StatusItem(style: .leading) {
				Text("Line")
			}
			StatusItem(style: .middle) {
				Text("0-0")
			}
			StatusItem(style: .trailing) {
				Text("3")
			}
		}
		.font(Font(theme.font(for: .statusLabel, context: context)))
	}
}

#Preview {
    LineSelectionItem()
}
