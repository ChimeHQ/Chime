import Foundation
import SwiftUI
import NSUI

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

		#if os(macOS)
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
		#endif
	}

	public struct Context {
		public var controlActiveState: NSUIControlActiveState
		public var hover: Bool
		public var colorScheme: ColorScheme

		public init(controlActiveState: NSUIControlActiveState = .active, hover: Bool = false, colorScheme: ColorScheme) {
			self.controlActiveState = controlActiveState
			self.hover = hover
			self.colorScheme = colorScheme
		}
	}

	public init() {
	}
}

extension Theme {
	public func color(for target: Target, context: Context) -> NSUIColor {
		switch target {
		case .source:
			NSUIColor.label
		case .insertionPoint:
			NSUIColor.label
		case .background:
			NSUIColor.systemBackground
		case .statusBackground:
			NSUIColor.gray
		case .statusLabel:
			NSUIColor.white
		case let .syntaxSpecifier(name):
			resolveSyntaxColor(for: name)
		}
	}

	private func resolveSyntaxColor(for specifier: String) -> NSUIColor {
		syntaxColor(for: specifier) ?? NSUIColor.label
	}

	private func syntaxColor(for name: String) -> NSUIColor? {
		switch name {
		case "type":
			NSUIColor(hex: "#8FBCBB")
		case "member.constructor", "invocation.function", "member.method":
			NSUIColor(hex: "#88C0D0")
		case "parameter", "member.property":
			NSUIColor(hex: "#D8DEE9")
		case "invocation.macro":
			NSUIColor(hex: "#526B9E")
		case "keyword.return", "keyword.function", "keyword", "keyword.loop", "keyword.include", "keyword.conditional":
			NSUIColor(hex: "#81A1C1")
		case "keyword.operator.text", "keyword.operator":
			NSUIColor(hex: "#81A1C1")
		case "label":
			NSUIColor(hex: "#526B9E")
		case "comment":
			NSUIColor(hex: "#4C566A")
		case "literal.string", "literal.regex":
			NSUIColor(hex: "#A3BE8C")
		case "literal.boolean", "literal.float", "literal.number":
			NSUIColor(hex: "#B48EAD")
		case "variable", "variable.builtin":
			NSUIColor(hex: "#D8DEE9")
		default:
			nil
		}
	}
}

extension Theme {
	private var defaultFont: NSUIFont {
		NSUIFont(name: "SF Mono", size: 12.0) ?? .monospacedSystemFont(ofSize: 12.0, weight: .regular)
	}

	public func font(for target: Target, context: Context) -> NSUIFont {
		defaultFont
	}
}

extension Theme {
	public var isDark: Bool {
		// TODO: this is not a great way to calculate the theme being dark
		NSUIColor.systemBackground.relativeLuminance > 0.5
	}
}

extension Theme {
	public func typingAttributes(tabWidth: Int, context: Context) -> [NSAttributedString.Key : Any] {
		let baseFont = font(for: .source, context: context)

		let charWidth = baseFont.advancementForSpaceGlyph
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
#if os(macOS)
	@MainActor
	public init(window: NSWindow?) {
		self.init(appearance: window?.appearance)
	}

	@MainActor
	public init(appearance: NSAppearance?) {
		let dark = appearance?.isDark == true

		self.init(controlActiveState: .inactive, hover: false, colorScheme: dark ? .dark : .light)
	}
#endif
}
