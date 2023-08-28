import SwiftUI

import Theme
import UIUtility

struct StatusItem<Content: View>: View {
	enum Style {
		case single
		case leading
		case trailing
		case middle
	}

	@Environment(\.theme) private var theme
	@Environment(\.controlActiveState) private var controlActiveState
	@Environment(\.colorScheme) private var colorScheme

	private let content: Content
	let style: Style

	init(style: Style = .single, _ contentProvider: () -> Content) {
		self.style = style
		self.content = contentProvider()
	}

	private var corners: RectCorner {
		switch style {
		case .single:
			return .all
		case .leading:
			return [.bottomLeft, .topLeft]
		case .trailing:
			return [.bottomRight, .topRight]
		case .middle:
			return []
		}
	}

	private var trailingSpacer: Bool {
		switch style {
		case .single, .trailing:
			return false
		case .leading, .middle:
			return true
		}
	}

	private var edgeInsets: EdgeInsets {
		EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0)
	}

	private var context: Theme.Context {
		.init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
	}

	private var color: Color {
		Color(theme.color(for: .statusLabel, context: context))
	}

	var body: some View {
		content
			.foregroundStyle(color)
			.padding(edgeInsets)
			.background(ItemBackground(corners: corners))
			.padding(.trailing, trailingSpacer ? 2.0 : 0.0)
	}
}

#Preview {
	Group {
		StatusItem(style: .single) {
			Text("hello")
		}
		.previewDisplayName("single")

		StatusItem(style: .leading) {
			Text("hello")
		}
		.previewDisplayName("leading")

		StatusItem(style: .trailing) {
			Text("hello")
		}
		.previewDisplayName("trailing")

		StatusItem(style: .middle) {
			Text("hello")
		}
		.previewDisplayName("middle")
	}
	.background(Rectangle().foregroundColor(.red))
}
