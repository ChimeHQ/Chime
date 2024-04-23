import AppKit

import ThemePark

public typealias Query = ThemePark.Query

extension Query.Context {
#if os(macOS)
	@MainActor
	public init(window: NSWindow?) {
		self.init(appearance: window?.appearance)
	}

	@MainActor
	public init(appearance: NSAppearance?) {
		let dark = appearance?.isDark == true

		self.init(controlState: .inactive, colorScheme: dark ? .dark : .light)
	}
#endif
}
