import ThemePark

public typealias Query = ThemePark.Query

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension Query.Context {
	@MainActor
	public init(window: NSWindow?) {
		self.init(appearance: window?.appearance)
	}

	@MainActor
	public init(appearance: NSAppearance?) {
		let dark = appearance?.isDark == true

		self.init(controlState: .inactive, colorScheme: dark ? .dark : .light)
	}
}
#else
import UIKit

extension Query.Context {
	@MainActor
	public init(window: UIWindow?) {
		self.init(controlState: .inactive, colorScheme: .dark)
	}
}

#endif
