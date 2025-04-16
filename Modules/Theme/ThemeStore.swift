import Foundation

import ThemePark

@MainActor
public final class ThemeStore {
	private var themeCache = [Theme.Identity: Theme]()
	private var themeURLs = [Theme.Identity: URL]()

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
		for url in XcodeTheme.all {
			guard let theme = try? XcodeTheme(contentsOf: url) else { continue }

			let name = url.deletingPathExtension().lastPathComponent
			let identity = Theme.Identity(source: .xcode, name: name)

			cacheStyler(theme, with: identity)
			themeURLs[identity] = url
		}
#endif
	}

	private func loadTextMateThemes() {
#if os(macOS)
		for url in TextMateTheme.all {
			guard let theme = try? TextMateTheme(contentsOf: url) else { continue }

			let identity = Theme.Identity(source: .textmate, name: theme.name)

			cacheStyler(theme, with: identity)
			themeURLs[identity] = url
		}
#endif
	}

	private func loadBBEditThemes() {
#if os(macOS)
		for url in BBEditTheme.all {
			guard let theme = try? BBEditTheme(contentsOf: url) else { continue }

			let name = url.deletingPathExtension().lastPathComponent
			let identity = Theme.Identity(source: .bbedit, name: name)

			cacheStyler(theme, with: identity)
			themeURLs[identity] = url
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
		loadBBEditThemes()
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

	public static var copiedThemesURL: URL? {
		FileManager.default.appGroupContainerURL?.appending(path: "Themes")
	}

//	public static var availableIdentities: Set<Theme.Identity> {
//		guard let names = UserDefaults.sharedSuite?.array(forKey: "ThemeIdentities") as? [String] else {
//			return []
//		}
//
//		return Set(names.compactMap { Theme.Identity(storageString: $0) })
//	}

	public static var currentTheme: Theme? {
		guard let dirURL = Self.copiedThemesURL else {
			return nil
		}

		guard let storageString = UserDefaults.sharedSuite?.string(forKey: "CurrentTheme") else {
			return nil
		}

		guard let identity = Theme.Identity(storageString: storageString) else {
			return nil
		}

		let themeURL = dirURL.appending(path: identity.storageString, directoryHint: .notDirectory)

		do {
			switch identity.source {
			case .xcode:
				let theme = try XcodeTheme(contentsOf: themeURL)

				return Theme(identity: identity, styler: theme)
			case .textmate:
				let theme = try TextMateTheme(contentsOf: themeURL)

				return Theme(identity: identity, styler: theme)
			case .bbedit:
				let theme = try BBEditTheme(contentsOf: themeURL)

				return Theme(identity: identity, styler: theme)
			case .chime:
				assertionFailure("What are we supposed to do here exactly?")
				return Theme.fallback
			}
		} catch {
			print("failed to load current theme: ", error)

			return nil
		}
	}

	public func updateCurrentTheme(with identity: Theme.Identity) {
		UserDefaults.sharedSuite?.setValue(identity.storageString, forKey: "CurrentTheme")

		guard let url = Self.copiedThemesURL else {
			return
		}

		guard let source = themeURLs[identity] else {
			return
		}

		do {

			let destination = url.appending(path: identity.storageString, directoryHint: .notDirectory)

			try? FileManager.default.removeItem(at: destination)
			try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
			try FileManager.default.copyItem(at: source, to: destination)

		} catch {
			print("failed to write out current theme: ", error)
		}
	}
}
