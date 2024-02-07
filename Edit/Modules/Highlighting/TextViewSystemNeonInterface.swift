import Foundation

import DocumentContent
import Neon
import RangeState
import TextSystem

extension TextStorage: VersionedContent where Version : Equatable {
	public var currentVersion: Version {
		version()
	}

	public func length(for version: Version) -> Int? {
		length(version)
	}
}

@MainActor
public final class TextViewSystemNeonInterface {
	public typealias StyleProvider = (String) -> [NSAttributedString.Key: Any]

	private let styleProvider: StyleProvider
	private let textSystem: TextViewSystem

	public init(textSystem: TextViewSystem, styleProvider: @escaping StyleProvider) {
		self.styleProvider = styleProvider
		self.textSystem = textSystem
	}
}

extension TextViewSystemNeonInterface: TextSystemInterface {
	private func setAttributes(_ attrs: [NSAttributedString.Key : Any], in range: NSRange) {
		textSystem.textPresentation.applyRenderingStyle(attrs, range)
	}

	public func applyStyles(for application: TokenApplication) {
		if application.action == .replace, let range = application.range {
			setAttributes([:], in: range)
		}

		for token in application.tokens {
			let attrs = styleProvider(token.name)
			setAttributes(attrs, in: token.range)
		}
	}

	public var visibleRange: NSRange {
		textSystem.textLayout.visibleRange()
	}

	public var content: some VersionedContent {
		textSystem.storage
	}
}
