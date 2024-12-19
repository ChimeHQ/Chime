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

extension TextTarget {
	@MainActor
	public init(rangeTarget: RangeTarget) {
		switch rangeTarget {
		case .all:
			self = .all
		case let .range(range):
			self = .range(TextRange.range(range))
		case let .set(set):
			self = .set(set)
		}
	}
}

/// Provides semantic information about text.
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
	public var invalidationHandler: (TextTarget) -> Void = { _ in }

	public init(textSystem: TextViewSystem, languageDataStore: LanguageDataStore) {
		self.textSystem = textSystem
		self.languageDataStore = languageDataStore
	}

	public func documentContextChanged(from: DocumentContext, to: DocumentContext) {
		// changes that affect us are UTI and contentId
		if from.uti == to.uti && from.contentId == to.contentId {
			return
		}

		setUpClient(with: to.uti)
	}

	private func invalidate() {
		invalidationHandler(.all)
	}

	private func setUpClient(with utType: UTType) {
		self.state = .inactive

		let profile = languageDataStore.profile(for: utType)

		guard profile.language != nil else { return }

		let config = TreeSitterClient.Configuration(
			languageProvider: { [languageDataStore] in languageDataStore.languageConfiguration(with: $0) },
			contentProvider: { [textSystem] in textSystem.storage.layerContent(for: $0) },
			contentSnapshopProvider: { [textSystem] in textSystem.storage.layerContentSnapshot(for: $0) },
			lengthProvider: { [textSystem] in textSystem.storage.currentLength },
			invalidationHandler: { [unowned self] in self.invalidationHandler(.set($0)) },
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
			willApplyMutation: { self.willApplyMutation($0) },
			didApplyMutation: { self.didApplyMutation($0) }
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

	public func languageConfigurationChanged(for name: String) {
		treeSitterClient?.languageConfigurationChanged(for: name)
	}
}

extension SyntaxService {
	private func willApplyMutation(_ mutation: TextStorageMutation) {
		guard let client = treeSitterClient else { return }

		client.willChangeContent(in: mutation.range)
	}

	private func didApplyMutation(_ mutation: TextStorageMutation) {
		guard let client = treeSitterClient else { return }

		client.didChangeContent(in: mutation.range, delta: mutation.delta)
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
		TokenProvider(
			syncValue: { range in
				guard let client = self.treeSitterClient else {
					return nil
				}

				do {
					let queryParams = try self.highlightsQueryParams(for: range)
					guard let namedRanges = try client.highlightsProvider.sync(queryParams) else {
						return nil
					}

					return TokenApplication(namedRanges: namedRanges, range: range)
				} catch {
					self.logger.warning("Failed to get highlighting: \(error)")

					return TokenApplication.noChange
				}
			},
			mainActorAsyncValue: { range in
				guard let client = self.treeSitterClient else {
					return TokenApplication.noChange
				}

				do {
					let queryParams = try self.highlightsQueryParams(for: range)
					let namedRanges = try await client.highlightsProvider.async(queryParams)

					print("names:", namedRanges)
					return TokenApplication(namedRanges: namedRanges, range: range)
				} catch {
					self.logger.warning("Failed to get highlighting: \(error)")

					return TokenApplication.noChange
				}
			}
		)
	}
}
