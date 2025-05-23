import NSUI

import Theme
import ThemePark

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

		#if os(macOS)
		// this is a hack to ensure we actually do this when necessary. It really is the responcibility of the theme.
		switch name {
		case "text.strong":
			var attrs = style.attributes

			let font = (attrs[.font] as? PlatformFont) ?? fallbackFont

			attrs[.font] = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)

			return attrs
		case "text.emphasis":
			var attrs = style.attributes

			let font = (attrs[.font] as? PlatformFont) ?? fallbackFont

			attrs[.font] = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)

			return attrs
		default:
			break
		}
		#endif
		return style.attributes
	}
}
