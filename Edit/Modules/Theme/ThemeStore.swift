import Foundation

import ThemePark

@MainActor
public final class ThemeStore {
	private var themeCache = [Theme.Identity: Theme]()

	public init() {
	}

	/// Expects "Theme Name.source"
	public func theme(with identifier: String) -> Theme {
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
#if os(macOS)
		for (name, theme) in XcodeTheme.all {
			let identity = Theme.Identity(source: .xcode, name: name)

			cacheStyler(theme, with: identity)
		}
#endif
	}

	private func loadTextMateThemes() {
#if os(macOS)
		for theme in TextMateTheme.all {
			let identity = Theme.Identity(source: .textmate, name: theme.name)

			cacheStyler(theme, with: identity)
		}
#endif
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

extension ThemeStore {
	public static var currentThemeURL: URL? {
		FileManager.default.appGroupContainerURL?.appending(path: "CurrentTheme.json")
	}

	public static var currentTheme: Theme? {
		guard let url = ThemeStore.currentThemeURL else {
			return nil
		}

		do {
			let data = try Data(contentsOf: url)

			let codableTheme = try JSONDecoder().decode(CodableTheme.self, from: data)

			return Theme(identity: codableTheme.identity, styler: codableTheme.styler)
		} catch {
			print("failed to load current theme: ", error)

			return nil
		}
	}

	public func updateCurrentTheme(with identity: Theme.Identity) {
		guard let url = ThemeStore.currentThemeURL else {
			return
		}

		let theme = theme(with: identity)

		let codableTheme = CodableTheme(styler: CodableStyler(theme), identity: identity)

		do {
			let data = try JSONEncoder().encode(codableTheme)

			try data.write(to: url)
		} catch {
			print("failed to write out current theme: ", error)
		}
	}
}
