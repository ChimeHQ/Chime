import NSUI

import Theme
import ThemePark

extension NSUIFont {
	func applySymbolicTraits(_ traits: NSUIFontDescriptor.SymbolicTraits) -> NSUIFont {
		let descriptor = fontDescriptor.nsuiWithSymbolicTraits(traits) ?? fontDescriptor

		return NSUIFont(nsuiDescriptor: descriptor, size: pointSize) ?? self
	}
}

@MainActor
final class TokenStyleSource {
	private var theme: Theme = Theme.fallback
	private var context: Query.Context = Query.Context(window: nil)

	func updateTheme(_ theme: Theme, context: Query.Context) {
		self.theme = theme
		self.context = context
	}

	private var fallbackFont: PlatformFont {
		theme.font(for: Query(key: .syntax(.text(nil)), context: context)) ?? Theme.fallbackFont
	}

	func tokenStyle(for name: String) -> [NSAttributedString.Key : Any] {
		let style = theme.highlightsQueryCaptureStyle(for: name, context: context)

		// this is a hack to ensure we actually do this when necessary. It really is the responsibility of the theme.
		switch name {
		case "text.strong":
			var attrs = style.attributes

			let font = (attrs[.font] as? PlatformFont) ?? fallbackFont

			attrs[.font] = font.applySymbolicTraits(.traitBold)

			return attrs
		case "text.emphasis":
			var attrs = style.attributes

			let font = (attrs[.font] as? PlatformFont) ?? fallbackFont

			attrs[.font] = font.applySymbolicTraits(.traitItalic)

			return attrs
		default:
			break
		}

		return style.attributes
	}
}
