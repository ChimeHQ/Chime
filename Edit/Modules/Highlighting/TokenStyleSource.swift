import Foundation

import Theme

@MainActor
final class TokenStyleSource {
	private var theme: Theme = Theme.fallback

	func updateTheme(_ theme: Theme, context: Query.Context) {
		self.theme = theme
	}

	func tokenStyle(for name: String) -> [NSAttributedString.Key : Any] {
		let context = Query.Context(window: nil)

		return theme.highlightsQueryCaptureStyle(for: name, context: context).attributes
	}
}
