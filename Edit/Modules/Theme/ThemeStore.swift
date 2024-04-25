import Foundation

import ThemePark

@MainActor
public final class ThemeStore {
	private var themeCache = [Theme.Identity: Theme]()

	public init() {
	}

	/// Expects "Theme Name.source"
	public func theme(with identifier: String) -> Theme {
		print("looking up theme: ", identifier)
		let components = identifier.components(separatedBy: ".")
		guard components.count == 2 else {
			return .fallback
		}

		guard let source = Theme.Source(rawValue: components[1]) else {
			return .fallback
		}

		let identity = Theme.Identity(source: source, name: components[0])

		return theme(with: identity)
	}

	public func theme(with identity: Theme.Identity) -> Theme {
		if let theme = themeCache[identity] {
			return theme
		}

		switch identity.source {
		case .xcode:
			loadXcodeThemes()
			
			return themeCache[identity] ?? .fallback
		case .textmate:
			loadTextMateThemes()

			return themeCache[identity] ?? .fallback
		default:
			return .fallback
		}
	}

	private func loadXcodeThemes() {
		for (name, theme) in XcodeTheme.all {
			let identity = Theme.Identity(source: .xcode, name: name)

			cacheStyler(theme, with: identity)
		}
	}

	private func loadTextMateThemes() {
		for theme in TextMateTheme.all {
			let identity = Theme.Identity(source: .textmate, name: theme.name)

			cacheStyler(theme, with: identity)
		}
	}

	private func cacheStyler(_ styler: any Styling, with identity: Theme.Identity) {
		let cachingStyler = StylingCache(styler: styler)

		themeCache[identity] = Theme(identity: identity, styler: cachingStyler)
	}

	public var all: [Theme.Identity: Theme] {
//		if themeCache.isEmpty {
			loadXcodeThemes()
			loadTextMateThemes()
//		}

		return themeCache
	}
}
