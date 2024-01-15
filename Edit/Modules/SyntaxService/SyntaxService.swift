import Foundation
import os.log

import ChimeKit
import DocumentContent
import Neon
import RangeState
import SwiftTreeSitter
import SwiftTreeSitterLayer
import TextSystem
import TreeSitterClient
import UniformTypeIdentifiers
import Utility

@MainActor
public final class SyntaxService {
	private enum State {
		case inactive
		case active(TreeSitterClient, LanguageProfile)
	}

	private let logger = Logger(type: SyntaxService.self)
	private var state = State.inactive {
		didSet { invalidate() }
	}

	private let languageDataStore: LanguageDataStore
	private let textSystem: TextViewSystem
	private let invalidatorBuffer = RangeInvalidationBuffer()
	public var invalidationHandler: (IndexSet) -> Void {
		didSet {
			invalidatorBuffer.invalidationHandler = { [textSystem, invalidationHandler] target in
				let set = target.indexSet(with: textSystem.storage.currentLength)

				invalidationHandler(set)
			}	
		}
	}

	public init(textSystem: TextViewSystem, languageDataStore: LanguageDataStore) {
		self.textSystem = textSystem
		self.languageDataStore = languageDataStore
		self.invalidationHandler = { _ in }
	}

	public func documentContextChanged(from: DocumentContext, to: DocumentContext) {
		// changes that affect us are UTI and contentId
		if from.uti == to.uti && from.contentId == to.contentId {
			return
		}

		setUpClient(with: to.uti)
	}

	private func invalidate() {
		let fullRange = NSRange(0..<textSystem.storage.currentLength)

		invalidationHandler(IndexSet(integersIn: fullRange))
	}

	private func setUpClient(with utType: UTType) {
		self.state = .inactive

		let profile = languageDataStore.profile(for: utType)

		guard profile.language != nil else { return }

		let config = TreeSitterClient.Configuration(
			languageProvider: languageDataStore.languageConfiguration(with:),
			contentProvider: { [textSystem] in textSystem.storage.layerContent(for: $0) },
			lengthProvider: { [textSystem] in textSystem.storage.currentLength },
			invalidationHandler: { [unowned self] in self.invalidationHandler($0) },
			locationTransformer: { [textSystem] in textSystem.textMetrics.locationTransformer($0) }
		)

		Task {
			do {
				let languageConfig = try await languageDataStore.loadLanguageConfiguration(with: utType, identifier: profile.name)!

				let client = try TreeSitterClient(rootLanguageConfig: languageConfig, configuration: config)

				logger.info("HybridTreeSitterClient set up")
				
				self.state = .active(client, profile)
			} catch {
				logger.error("Failed to set up HybridTreeSitterClient: \(error, privacy: .public)")
			}
		}
	}

	public var storageMonitor: TextStorageMonitor {
		.init(
			willApplyMutations: { self.willApplyMutations($0) },
			didApplyMutations: { self.didApplyMutations($0) },
			didCompleteMutations: { [invalidatorBuffer] _ in
				invalidatorBuffer.endBuffering()
			}
		)
	}
	
	private var treeSitterClient: TreeSitterClient? {
		switch state {
		case .inactive:
			return nil
		case let .active(client, _):
			return client
		}
	}

	private static let highlightsMap: [String: String] = [
		"keyword": "keyword",
		"include": "keyword.include",
		"keyword.return": "keyword.return",
		"keyword.function": "keyword.function",
		"keyword.operator": "keyword.operator.text",
		"operator": "keyword.operator",
		"conditional": "keyword.conditional",
		"repeat": "keyword.loop",
		"punctuation.special": "keyword.operator.text",
		"punctuation.delimiter": "keyword.operator.text",

		"type": "type",

		"string": "literal.string",
		"number": "literal.number",
		"float": "literal.float",
		"boolean": "literal.boolean",
		"string.regex": "literal.regex",
		"text.literal": "literal.string",
		"string.escape": "literal.string.escape",
		"text.uri": "literal.string.uri",
		"string.uri": "literal.string.uri",

		"variable": "variable",
		"variable.builtin": "variable.built-in",

		"method": "member.function",
		"constructor": "member.constructor",
		"property": "member.property",

		"parameter": "parameter",
		"function": "function",
		"function.call": "invocation.function",
		"function.macro": "invocation.macro",

		"label": "label",
		"text.reference": "label",
	]

	public func languageConfigurationChanged(for name: String) {
		treeSitterClient?.languageConfigurationChanged(for: name)
	}
}

extension SyntaxService {
	private func willApplyMutations(_ mutations: [TextStorageMutation]) {
		invalidatorBuffer.beginBuffering()

		guard let client = treeSitterClient else { return }

		for mutation in mutations.flatMap({ $0.stringMutations}) {
			client.willChangeContent(in: mutation.range)
		}
	}

	private func didApplyMutations(_ mutations: [TextStorageMutation]) {
		guard let client = treeSitterClient else { return }

		for mutation in mutations.flatMap({ $0.stringMutations}) {
			client.didChangeContent(in: mutation.range, delta: mutation.delta)
		}
	}
}

extension SyntaxService {
	private func highlightsQueryParams(for range: NSRange) throws -> TreeSitterClient.ClientQueryParams {
		// TODO: this is really not good
		let fullRange = NSRange(0..<self.textSystem.storage.currentLength)
		let fullString = try self.textSystem.storage.substring(with: fullRange)
		let textProvider = fullString.predicateTextProvider

		return TreeSitterClient.ClientQueryParams(range: range, textProvider: textProvider, mode: .optional)
	}

	public var tokenProvider: TokenProvider {
		HybridValueProvider<NSRange, [NamedRange]>(
			syncValue: { range in
				guard let client = self.treeSitterClient else {
					return []
				}

				do {
					let queryParams = try self.highlightsQueryParams(for: range)

					return try client.highlightsProvider.sync(queryParams)
				} catch {
					self.logger.warning("Failed to get highlighting: \(error)")

					return []
				}
			},
			asyncValue: { range in
				guard let client = self.treeSitterClient else {
					return []
				}

				do {
					let queryParams = try self.highlightsQueryParams(for: range)

					return try await client.highlightsProvider.async(queryParams)
				} catch {
					self.logger.warning("Failed to get highlighting: \(error)")

					return []
				}
			}
		).map { namedRange in
			let tokens = namedRange.map {
				let name = Self.highlightsMap[$0.name] ?? $0.name

				return Token(name: name, range: $0.range)
			}

			return TokenApplication(tokens: tokens)
		}
	}
}
