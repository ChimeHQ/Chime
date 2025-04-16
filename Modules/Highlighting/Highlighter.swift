import AppKit
import Foundation
import UniformTypeIdentifiers

import ChimeKit
import DocumentContent
import Lowlight
import Neon
import RangeState
import Rearrange
import SyntaxService
import TextSystem
import Theme
import ThemePark

@MainActor
final class LowlightTokenProvider {
	private let textSystem: TextViewSystem
	private var processor: Lowlight.Processor?

	init(textSystem: TextViewSystem) {
		self.textSystem = textSystem
	}

	func process(_ range: NSRange) -> TokenApplication {
		guard let value = try? textSystem.storage.substring(with: range) else {
			return .noChange
		}

		guard let output = processor?.process(value) else {
			return .noChange
		}

		let start = range.location
		let neonTokens = output.tokens.map {
			let shiftedRange = $0.range.shifted(by: start)!
			
			return Neon.Token(name: $0.element.treeSitterHighlightName, range: shiftedRange)
		}

		return .init(tokens: neonTokens)
	}

	public func documentContextChanged(from oldContext: DocumentContext, to newContext: DocumentContext) {
		if oldContext.uti == newContext.uti {
			return
		}
		
		guard let language = language(for: newContext.uti) else {
			self.processor = nil
			return
		}

		self.processor = Processor(language: language)
 	}

	private func language(for utType: UTType) -> Language? {
		if utType.conforms(to: .goSource) {
			return Language(patterns: [])
		}

		if utType.conforms(to: .swiftSource) {
			return Language.swift
		}

		if utType.conforms(to: .markdown) {
//			return Language(keywords: [], symbols: ["#"])
			return Language(patterns: [])
		}

		return nil
	}
}

/// Manages syntax highlighting state.
@MainActor
public final class Highlighter<Service: TokenService> {
	typealias Styler = ThreePhaseTextSystemStyler<TextViewSystemNeonInterface>

	private let styleSource: TokenStyleSource
	private let textSystem: TextViewSystem
	private let styler: Styler
	private let invalidVisualizationAttrs: [NSAttributedString.Key : Any]
	private let tokenServiceWrapper: TokenServiceWrapper<Service>
	private let invalidatorBuffer = RangeInvalidationBuffer()
	private let lowlightTokenProvider: LowlightTokenProvider

	/// Highlight invalidated regions first, and then apply regular highlighting.
	///
	/// This has a performance cost. And, as currently implemented, also probably works incorrectly when the document is being edited.
	public var visualizeInvalidations = false

	public init(textSystem: TextViewSystem, syntaxService: SyntaxService) {
		self.textSystem = textSystem
		self.tokenServiceWrapper = TokenServiceWrapper(textSystem: textSystem)
		self.lowlightTokenProvider = LowlightTokenProvider(textSystem: textSystem)

		// this is using the same style source for all tyoes of providers and I don't think that makes sense
		self.styleSource = TokenStyleSource()

		let interface = TextViewSystemNeonInterface(textSystem: textSystem, styleProvider: styleSource.tokenStyle)

		let secondary: Styler.SecondaryValidationProvider = { [tokenServiceWrapper] in
			return await tokenServiceWrapper.tokens(for: $0)
		}

		// Don't forget about `TokenProvider.none` and `asyncOnlyNone` when debugging here. They are handy!
		self.styler = ThreePhaseTextSystemStyler(
			textSystem: interface,
			tokenProvider: syntaxService.tokenProvider,
			fallbackHandler: lowlightTokenProvider.process,
			secondaryValidationProvider: secondary
		)

		self.invalidVisualizationAttrs = [
			.backgroundColor: NSColor(red: 1.0, green: 0.0, blue: 0.1, alpha: 0.7)
		]

		invalidatorBuffer.invalidationHandler = { [unowned self] target in
			self.applyInvalidation(target)
		}
	}

	public func invalidate(textTarget target: TextTarget) {
		let query = TextMetricsCalculator.Query(textTarget: target, fill: .optional, useEntireDocument: false)
		guard let metrics = textSystem.textMetricsCalculator.valueProvider.sync(query) else {
			invalidate(.all)
			return
		}

		guard let rangeTarget = RangeTarget(textTarget: target, metrics: metrics) else {
			invalidate(.all)
			return
		}

		invalidate(rangeTarget)
	}
	
	public func invalidate(_ target: RangeTarget) {
		invalidatorBuffer.invalidate(target)
	}

	private func relayInvalidation(_ target: RangeTarget) {
		styler.invalidate(target)

		// only re-validate what is currently visible
		visibleContentDidChange()
	}
	
	private func applyInvalidation(_ target: RangeTarget) {
		guard visualizeInvalidations else {
			relayInvalidation(target)
			return
		}

		let invalidtedSet = target.indexSet(with: textSystem.storage.currentLength)
		let ranges = invalidtedSet.nsRangeView

		for range in ranges {
			textSystem.textPresentation.applyRenderingStyle(invalidVisualizationAttrs, range)
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
			for range in ranges {
				self.textSystem.textPresentation.applyRenderingStyle([:], range)
			}

			self.relayInvalidation(target)
		}
	}

	public func visibleContentDidChange() {
		let visibleSet = textSystem.textLayout.visibleSet()

//		styler.validate(RangeTarget.set(visibleSet))
		styler.validate()
	}

	public var name: String? {
		get { styler.name }
		set { styler.name = newValue }
	}

	public func updateTheme(_ theme: Theme, context: Query.Context) {
		styleSource.updateTheme(theme, context: context)

		print("about to do something inefficient")
		let fullRange = NSRange(0..<textSystem.storage.currentLength)
		textSystem.textPresentation.applyRenderingStyle([:], fullRange)

		styler.invalidate(.all)
		styler.validate()
	}

	public var tokenService: Service? {
		get { tokenServiceWrapper.service }
		set {
			// avoid an invalidation if we aren't making a real change
			if tokenServiceWrapper.service == nil && newValue == nil {
				return
			}

			tokenServiceWrapper.service = newValue

			invalidate(RangeTarget.all)
		}
	}

	public func documentContextChanged(from oldContext: DocumentContext, to newContext: DocumentContext) {
		lowlightTokenProvider.documentContextChanged(from: oldContext, to: newContext)
	}

	public var storageMonitor: TextStorageMonitor {
		.init(
			willApplyMutation: { _ in },
			didApplyMutation: { self.didApplyMutation($0) }
		)
		.withInvalidationBuffer(invalidatorBuffer)
	}

	private func didApplyMutation(_ mutation: TextStorageMutation) {
		styler.didChangeContent(in: mutation.range, delta: mutation.delta)
	}
}
