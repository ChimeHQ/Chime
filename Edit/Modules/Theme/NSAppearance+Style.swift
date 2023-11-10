import Cocoa

// From: https://github.com/ChimeHQ/Dusk

extension NSAppearance {
	/// Indicates if the receiver is a dark theme
	public var isDark: Bool {
		switch name {
		case .darkAqua, .accessibilityHighContrastDarkAqua:
			return true
		case .vibrantDark, .accessibilityHighContrastVibrantDark:
			return true
		default:
			return false
		}
	}

	/// Attempts to determine the most reasonable opposite-themed appearance
	public var oppositeAppearance: NSAppearance? {
		switch name {
		case .darkAqua, .accessibilityHighContrastDarkAqua:
			return NSAppearance(named: .aqua)
		case .vibrantDark, .accessibilityHighContrastVibrantDark:
			return NSAppearance(named: .vibrantLight)
		case .aqua, .accessibilityHighContrastAqua:
			return NSAppearance(named: .darkAqua)
		case .vibrantLight, .accessibilityHighContrastVibrantLight:
			return NSAppearance(named: .vibrantDark)
		default:
			return self
		}
	}
}

extension Theme.Context {
	@MainActor
	public init(window: NSWindow?) {
		self.init(appearance: window?.appearance)
	}

	@MainActor
	public init(appearance: NSAppearance?) {
		let dark = appearance?.isDark == true

		self.init(controlActiveState: .inactive, hover: false, colorScheme: dark ? .dark : .light)
	}
}
