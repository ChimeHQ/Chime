import SwiftUI

import Theme
import UIUtility

struct ItemBackground: View {
	@Environment(\.theme) private var theme
	@Environment(\.controlActiveState) private var controlActiveState
	@Environment(\.colorScheme) private var colorScheme

	let corners: RectCorner

	private var context: Theme.Context {
		.init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
	}
	
	private var color: Color {
		Color(theme.color(for: .statusBackground, context: context))
	}

	var body: some View {
		Rectangle()
			.foregroundColor(color)
			.cornerRadius(4.0, corners: corners)
	}
}

#Preview {
	ItemBackground(corners: .all)
}
