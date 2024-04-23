import SwiftUI

import ThemePark

public struct ThemeKey: EnvironmentKey {
	public static let defaultValue = Theme.fallback
}

extension EnvironmentValues {
	public var theme: Theme {
		get { self[ThemeKey.self] }
		set { self[ThemeKey.self] = newValue }
	}
}

struct ThemedColorQueryModifier: ViewModifier {
	@Environment(\.theme) private var theme

	let key: Query.Key

	func body(content: Content) -> some View {
		content
			.foregroundThemeColor(key, styler: theme)
	}
}

extension View {
	public func foregroundThemeColor(_ key: Query.Key) -> some View {
		modifier(ThemedColorQueryModifier(key: key))
	}
}

struct ThemedFontQueryModifier: ViewModifier {
	@Environment(\.theme) private var theme

	let key: Query.Key
	let fallback: PlatformFont

	func body(content: Content) -> some View {
		content
			.foregroundThemeColor(key, styler: theme)
	}
}

extension View {
	public func themeFont(_ key: Query.Key) -> some View {
		modifier(ThemedFontQueryModifier(key: key, fallback: .systemFont(ofSize: 12.0)))
	}
}
