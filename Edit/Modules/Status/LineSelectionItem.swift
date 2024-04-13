import SwiftUI

import Theme

struct LineSelectionItem: View {
	@Environment(\.documentCursors) private var cursors

	var body: some View {
		LabelledSpanCount(
			"Line",
			spanPair: ("0", "0"),
			countPair: ("3", "0")
		)
	}
}

#Preview {
    LineSelectionItem()
}
