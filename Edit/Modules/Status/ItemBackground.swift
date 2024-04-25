import SwiftUI

import Theme
import UIUtility

struct ItemBackground: View {
	@Environment(\.theme) private var theme

	let corners: RectCorner

	var body: some View {
		Rectangle()
			.foregroundThemeColor(.editor(.accessoryBackground))
			.cornerRadius(4.0, corners: corners)
	}
}

#Preview {
	ItemBackground(corners: .all)
}
