import Foundation
import OSLog
import UniformTypeIdentifiers

import RangeState
import SwiftTreeSitter
import Utility

extension UTType {
	static let markdownInline = UTType(importedAs: "net.daringfireball.markdown.inline", conformingTo: .markdown)
}

/// A store for all language information.
@MainActor
public final class LanguageDataStore {
	public static let global = LanguageDataStore()
	
	private var configurationCache = [UTType : LanguageConfiguration]()
	private var profileCache: [UTType : LanguageProfile]
	private var loadingSet = Set<String>()
	private let logger = Logger(type: LanguageDataStore.self)

	public var configurationLoaded: (String) -> Void = { _ in }

	public init() {
		// prime the cache for the common case
		self.profileCache = [
			.plainText: LanguageProfile.genericProfile
		]
	}

	public func profile(for utType: UTType) -> LanguageProfile {
		if let value = profileCache[utType] {
			return value
		}

		let profile = LanguageProfile.profile(for: utType)

		self.profileCache[utType] = profile

		return profile
	}
}

extension LanguageDataStore {
	private func languageDocumentType(from identifier: String) -> UTType {
		if let lang = RootLanguage(rawValue: identifier) {
			return lang.typeIdentifier
		}

		// use the same normalization rules, but check for non-root languages
		let name = RootLanguage.normalizeLanguageName(identifier)

		switch name {
		case "markdown_inline":
			return .markdownInline
		default:
			logger.warning("Unhandled language name: \(identifier, privacy: .public)")
			return .plainText
		}
	}

	private func profile(for identifier: String) -> LanguageProfile {
		let utType = languageDocumentType(from: identifier)

		return profile(for: utType)
	}

	public func languageConfiguration(with identifier: String, background: Bool = true) -> LanguageConfiguration? {
		let utType = languageDocumentType(from: identifier)

		// shortcut this
		if utType == .plainText {
			return nil
		}

		if let value = configurationCache[utType] {
			return value
		}

		if background == false {
			if let value = configurationCache[utType] {
				return value
			}

			let profile = profile(for: utType)

			let config = try? profile.load()

			self.configurationCache[utType] = config

			return config
		}

		Task<Void, Never> {
			logger.info("Beginning background language config loading for \(identifier, privacy: .public)")

			do {
				_ = try await loadLanguageConfiguration(with: utType, identifier: identifier)
				
				logger.info("Load complete for \(identifier, privacy: .public)")
			} catch {
				logger.error("Failed to load config for \(identifier, privacy: .public), \(error, privacy: .public)")
			}
		}

		return nil
	}

	public func loadLanguageConfiguration(with utType: UTType, identifier: String) async throws -> LanguageConfiguration? {
		if let value = configurationCache[utType] {
			return value
		}

		let profile = profile(for: utType)
		let lang = profile.language
		let name = profile.name
		let bundleName = profile.bundleName

		async let config = LanguageProfile.loadConfiguration(
			language: lang,
			name: name,
			bundleName: bundleName
		)

		let loadedConfig = try await config
		
		self.configurationCache[utType] = loadedConfig

		configurationLoaded(identifier)

		return loadedConfig
	}

	public func loadLanguageConfiguration(with utType: UTType) async throws -> LanguageConfiguration? {
		let profile = profile(for: utType)

		return try await loadLanguageConfiguration(with: utType, identifier: profile.name)
	}
}
