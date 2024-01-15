import Foundation
import SwiftUI

import ColorToolbox
import Utility

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

		case syntaxSpecifier(String)
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
		case let .syntaxSpecifier(name):
			resolveSyntaxColor(for: name)
		}
	}

	private func resolveSyntaxColor(for specifier: String) -> NSColor {
		syntaxColor(for: specifier) ?? NSColor.textColor
	}

	private func syntaxColor(for name: String) -> NSColor? {
		switch name {
		case "type":
			NSColor(hex: "#8FBCBB")
		case "member.constructor", "invocation.function", "member.method":
			NSColor(hex: "#88C0D0")
		case "parameter", "member.property":
			NSColor(hex: "#D8DEE9")
		case "invocation.macro":
			NSColor(hex: "#526B9E")
		case "keyword.return", "keyword.function", "keyword", "keyword.loop", "keyword.include", "keyword.conditional":
			NSColor(hex: "#81A1C1")
		case "keyword.operator.text", "keyword.operator":
			NSColor(hex: "#81A1C1")
		case "label":
			NSColor(hex: "#526B9E")
		case "comment":
			NSColor(hex: "#4C566A")
		case "literal.string", "literal.regex":
			NSColor(hex: "#A3BE8C")
		case "literal.boolean", "literal.float", "literal.number":
			NSColor(hex: "#B48EAD")
		case "variable", "variable.builtin":
			NSColor(hex: "#D8DEE9")
		default:
			nil
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

extension Theme {
	public var isDark: Bool {
		// TODO: this is not correct...
		guard let color = NSColor.windowBackgroundColor.usingColorSpace(.deviceRGB) else { return false }

		return color.brightnessComponent < 0.5
	}
}

extension Theme {
	public func typingAttributes(tabWidth: Int, context: Context) -> [NSAttributedString.Key : Any] {
		let baseFont = font(for: .source, context: context)

		let charWidth = baseFont.advancementForSpaceGlyph.width
		let indentationWidth = charWidth * CGFloat(tabWidth)

		let style = NSParagraphStyle.with { style in
			style.tabStops = []
			style.defaultTabInterval = indentationWidth
		}

		return [
			.font: baseFont,
			.foregroundColor: color(for: .source, context: context),
			.paragraphStyle: style,
		]
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
