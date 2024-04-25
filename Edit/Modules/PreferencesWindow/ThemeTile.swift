import SwiftUI

import Theme
import ThemePark

struct ThemeTile: View {
	@Environment(\.styleQueryContext) private var context

	let theme: Theme
	let isSelected: Bool

	private var backgroundColor: Color {
		let color = theme.color(for: .init(key: .editor(.background), context: context))

		return Color(nsuiColor: color)
	}

    var body: some View {
		VStack {
			Rectangle()
				.clipShape(
					.rect(cornerRadius: 6.0)
				)
				.foregroundStyle(backgroundColor)
			Text(theme.name)
				.foregroundStyle(isSelected ? Color.blue : Color.primary)
			Text(theme.identity.source.rawValue)
		}.frame(width: 70 * 16.0/9.0, height: 70)
    }
}

#Preview {
	ThemeTile(theme: Theme.fallback, isSelected: false)
}
