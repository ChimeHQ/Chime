import SwiftUI

import DocumentContent
import TextSystem

@MainActor
struct StatusBarContent: View {
	@Environment(\.documentCursors) private var cursors
	@Environment(\.textViewSystem) private var textViewSystem
	@State private var model = SelectionViewModel()

	let searchCount: Int?

	var body: some View {
		HStack(spacing: 0) {
//			StatusItem {
//				ProgressView(message: progressMessage)
//			}
//			.modifier(BottomPushAndSlideEffect(visible: progressMessage != nil))
//			.padding(.trailing, progressMessage != nil ? 8.0 : 0.0)

			LineSelectionItem()
				.padding(.trailing, 8.0)

			CharacterSelectionItem()

			if let count = searchCount {
				SearchItem(count: count)
					.padding(.leading, 8.0)
					.transition(.move(edge: .trailing))

			}
		}
		.environment(model)
		.onChange(of: cursors) {
			model.cursorsChanged(cursors)
		}
		.onChange(of: textViewSystem, initial: true) {
			model.textViewSystem = textViewSystem
		}
	}
}

#Preview {
    StatusBarContent(searchCount: 1)
}
