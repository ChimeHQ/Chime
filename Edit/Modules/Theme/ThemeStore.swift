import Foundation

import ThemePark

@MainActor
public final class ThemeStore {
	private var themeCache = [Theme.Identity: Theme]()

	public init() {
	}

	/// Expects "Theme Name.source"
	public func theme(with identifier: String) -> Theme {
		guard let identity = Theme.Identity(storageString: identifier) else {
			return .fallback
		}

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

	private func loadThemes() {
		loadXcodeThemes()
		loadTextMateThemes()

		guard let containerURL = FileManager.default.appGroupContainerURL else { return }

		let themeCacheDir = containerURL.appending(path: "Library/Caches/Themes", directoryHint: .isDirectory)

		try? FileManager.default.createDirectory(at: themeCacheDir, withIntermediateDirectories: true)

		for (identity, theme) in themeCache {
			let codableTheme = CodableTheme(styler: CodableStyler(theme), identity: identity)
			let url = themeCacheDir.appending(path: identity.storageString, directoryHint: .notDirectory)

			do {
				let data = try JSONEncoder().encode(codableTheme)

				try data.write(to: url)
			} catch {
				print("failed to write out current theme: ", error)
			}
		}

		let names = themeCache.keys.map { $0.storageString }
		UserDefaults.sharedSuite?.setValue(names, forKey: "ThemeIdentities")

		print(Self.availableIdentities)
	}

	public var all: [Theme.Identity: Theme] {
		loadThemes()

		return themeCache
	}
}

extension ThemeStore {
	public static var currentThemeURL: URL? {
		FileManager.default.appGroupContainerURL?.appending(path: "CurrentTheme.json")
	}

	public static var availableIdentities: Set<Theme.Identity> {
		guard let names = UserDefaults.sharedSuite?.array(forKey: "ThemeIdentities") as? [String] else {
			return []
		}

		return Set(names.compactMap { Theme.Identity(storageString: $0) })
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
