import Foundation

import Theme

@MainActor
final class TokenStyleSource {
	private var theme: Theme = Theme()

	func updateTheme(_ theme: Theme, context: Theme.Context) {
		self.theme = theme
	}

	func tokenStyle(for name: String) -> [NSAttributedString.Key : Any] {
		let context = Theme.Context(window: nil)

		return theme.syntaxStyle(for: name, context: context)
	}
}
