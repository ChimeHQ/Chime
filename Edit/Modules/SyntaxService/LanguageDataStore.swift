import Foundation
import UniformTypeIdentifiers

import RangeState
import SwiftTreeSitter

extension UTType {
	static let markdownInline = UTType(importedAs: "net.daringfireball.markdown.inline", conformingTo: .markdown)
}

/// A store for all language information.
@MainActor
public final class LanguageDataStore {
	public static let global = LanguageDataStore()
	
	private var configurationCache = [UTType : LanguageConfiguration]()
	private var profileCache = [UTType : LanguageProfile]()
	private var loadingSet = Set<String>()

	public var configurationLoaded: (String) -> Void = { _ in }

	public init() {
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
	private static func languageDocumentType(from identifier: String) -> UTType {
		if let lang = RootLanguage(rawValue: identifier) {
			return lang.typeIdentifier
		}

		// use the same normalization rules, but check for non-root languages
		let name = RootLanguage.normalizeLanguageName(identifier)

		switch name {
		case "markdown_inline":
			return .markdownInline
		default:
			return .plainText
		}
	}

	private func profile(for identifier: String) -> LanguageProfile {
		let utType = Self.languageDocumentType(from: identifier)

		return profile(for: utType)
	}

	public func languageConfiguration(with identifier: String, background: Bool = true) -> LanguageConfiguration? {
		let utType = LanguageDataStore.languageDocumentType(from: identifier)

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

		Task {
			_ = try! await loadLanguageConfiguration(with: utType, identifier: identifier)
		}

		return nil
	}

	public func loadLanguageConfiguration(with utType: UTType, identifier: String) async throws -> LanguageConfiguration? {
		if let value = configurationCache[utType] {
			return value
		}

		let profile = profile(for: utType)

		let config = try await profile.loadLanguageConfiguration()

		self.configurationCache[utType] = config

		configurationLoaded(identifier)

		return config
	}

	public func loadLanguageConfiguration(with utType: UTType) async throws -> LanguageConfiguration? {
		let profile = profile(for: utType)

		return try await loadLanguageConfiguration(with: utType, identifier: profile.name)
	}
}
