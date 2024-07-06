import Foundation
import SwiftUI

import ThemePark
import Utility

public struct Theme {
	public enum Source: String, Codable, Sendable {
		case chime
		case xcode
		case bbedit
		case textmate

		public var name: String {
			switch self {
			case .chime: "Chime"
			case .xcode: "Xcode"
			case .bbedit: "BBEdit"
			case .textmate: "TextMate"
			}
		}
	}

	public struct Identity: Hashable, Codable, Sendable {
		public let source: Source
		public let name: String

		public var storageString: String {
			"\(name).\(source)"
		}

		public init(source: Source, name: String) {
			self.source = source
			self.name = name
		}
		public init?(storageString: String) {
			let components = storageString.components(separatedBy: ".")
			guard components.count == 2 else {
				return nil
			}

			guard let source = Theme.Source(rawValue: components[1]) else {
				return nil
			}

			self.init(source: source, name: components[0])
		}
	}

	public let identity: Identity
	private let internalStyler: any Styling

	public init(identity: Identity, styler: any Styling) {
		self.identity = identity
		self.internalStyler = styler
	}
	
	public var name: String {
		identity.name
	}
}

extension Theme: Styling {
	public var supportedVariants: Set<ThemePark.Variant> {
		internalStyler.supportedVariants
	}
	
	public func style(for query: Query) -> ThemePark.Style {
		internalStyler.style(for: query)
	}
}

extension Theme {
	@MainActor
	public static let fallback = Theme(
		identity: .init(source: .chime, name: "Fallback"),
		styler: ConstantStyler(foregroundColor: .label, backgroundColor: .windowBackgroundColor)
	)

	@MainActor
	public static let fallbackFont: PlatformFont =
		PlatformFont(name: "SF Mono", size: 12.0) ?? .monospacedSystemFont(ofSize: 12.0, weight: .regular)
}

extension Theme {
	@MainActor
	public func typingAttributes(tabWidth: Int, context: Query.Context) -> [NSAttributedString.Key : Any] {
		let query = Query(key: .syntax(.text), context: context)

		let baseFont = font(for: query) ?? Self.fallbackFont

		let charWidth = baseFont.advancementForSpaceGlyph
		let indentationWidth = charWidth * CGFloat(tabWidth)

		let style = NSParagraphStyle.with { style in
			style.tabStops = []
			style.defaultTabInterval = indentationWidth
		}

		return [
			.font: baseFont,
			.foregroundColor: color(for: query),
			.paragraphStyle: style,
		]
	}
}

