import Foundation
import SwiftUI

public struct ThemeKey: EnvironmentKey {
	public static let defaultValue = Theme()
}

extension EnvironmentValues {
	public var theme: Theme {
		get { self[ThemeKey.self] }
		set { self[ThemeKey.self] = newValue }
	}
}

public struct Theme: Hashable, Sendable {
	public enum Target: Hashable, Sendable {
		case source
		case insertionPoint
		case background

		case statusBackground
		case statusLabel
	}

	public enum ControlState {
		case active
		case inactive
		case hover

		init(controlActiveState: ControlActiveState) {
			switch controlActiveState {
			case .active, .key:
				self = .active
			case .inactive:
				self = .inactive
			@unknown default:
				self = .active
			}
		}
	}

	public struct Context {
		public var controlActiveState: ControlActiveState
		public var hover: Bool
		public var colorScheme: ColorScheme

		public init(controlActiveState: ControlActiveState = .active, hover: Bool = false, colorScheme: ColorScheme) {
			self.controlActiveState = controlActiveState
			self.hover = hover
			self.colorScheme = colorScheme
		}
	}

	public init() {
	}
}

extension Theme {
	public func color(for target: Target, context: Context) -> NSColor {
		switch target {
		case .source:
			NSColor.textColor
		case .insertionPoint:
			NSColor.textColor
		case .background:
			NSColor.windowBackgroundColor
		case .statusBackground:
			NSColor.green
		case .statusLabel:
			NSColor.white
		}
	}
}

extension Theme {
	private var defaultFont: NSFont {
		NSFont(name: "SF Mono", size: 12.0) ?? .monospacedSystemFont(ofSize: 12.0, weight: .regular)
	}

	public func font(for target: Target, context: Context) -> NSFont {
		defaultFont
	}
}

