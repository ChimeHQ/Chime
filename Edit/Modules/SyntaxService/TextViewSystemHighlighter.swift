import AppKit
import Foundation

import DocumentContent
import MainOffender
import Neon
import RangeState
import TextSystem
import Theme

extension TextStorage: VersionedContent where Version : Equatable {
	public var currentVersion: Version {
		version()
	}

	public func length(for version: Version) -> Int? {
		length(version)
	}
}

@MainActor
public final class TextViewSystemInterface {
	public typealias StyleProvider = (String) -> [NSAttributedString.Key: Any]

	private let styleProvider: StyleProvider
	private let textSystem: TextViewSystem

	public init(textSystem: TextViewSystem, styleProvider: @escaping StyleProvider) {
		self.styleProvider = styleProvider
		self.textSystem = textSystem
	}
}

extension TextViewSystemInterface: TextSystemInterface {
	private func setAttributes(_ attrs: [NSAttributedString.Key : Any], in range: NSRange) {
		textSystem.textPresentation.applyRenderingStyle(attrs, range)
	}

	public func applyStyles(for application: TokenApplication) {
		if let range = application.range {
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

@MainActor
final class TokenStyleSource {
	private var theme: Theme = Theme()

	func updateTheme(_ theme: Theme, context: Theme.Context) {
		self.theme = theme
	}

	func tokenStyle(for name: String) -> [NSAttributedString.Key : Any] {
		let context = Theme.Context(window: nil)

		return theme.syntaxStyle(for: name, context: context)
	}
}

@MainActor
public final class Highligher {
	private let styleSource: TokenStyleSource
	private let textSystem: TextViewSystem
	private let syntaxService: SyntaxService
	private let interface: TextViewSystemInterface
	private let invalidVisualizationAttrs: [NSAttributedString.Key : Any]
	private let styler: TextSystemStyler<TextViewSystemInterface>

	/// Highlight invalidated regions first, and then apply regular highlighting.
	///
	/// This has a performance cost. And, as currently implemented, also probably works incorrectly when the document is being edited.
	public var visualizeInvalidations = false

	public init(textSystem: TextViewSystem, syntaxService: SyntaxService) {
		self.styleSource = TokenStyleSource()
		self.interface = TextViewSystemInterface(textSystem: textSystem, styleProvider: styleSource.tokenStyle(for:))
		self.styler = TextSystemStyler<TextViewSystemInterface>(textSystem: interface, tokenProvider: syntaxService.tokenProvider)
		self.textSystem = textSystem
		self.syntaxService = syntaxService
		self.invalidVisualizationAttrs = [
			.backgroundColor: NSColor(red: 1.0, green: 0.0, blue: 0.1, alpha: 0.7)
		]
	}

	public func invalidate(_ target: RangeTarget) {
		guard visualizeInvalidations else {
			styler.invalidate(target)
			return
		}

		let invalidtedSet = target.indexSet(with: textSystem.storage.currentLength)
		let ranges = invalidtedSet.nsRangeView

		for range in ranges {
			textSystem.textPresentation.applyRenderingStyle(invalidVisualizationAttrs, range)
		}

		DispatchQueue.mainActor.asyncAfter(deadline: .now() + .milliseconds(300)) {
			for range in ranges {
				self.textSystem.textPresentation.applyRenderingStyle([:], range)
			}

			self.styler.invalidate(target)
		}
	}

	public func visibleContentDidChange() {
		styler.visibleContentDidChange()
	}
}

extension Highligher {
	public func updateTheme(_ theme: Theme, context: Theme.Context) {
		styleSource.updateTheme(theme, context: context)
		styler.invalidate(.all)
	}

	private func tokenAttributes(_ token: Token) -> [NSAttributedString.Key: Any] {
		styleSource.tokenStyle(for: token.name)
	}
}
