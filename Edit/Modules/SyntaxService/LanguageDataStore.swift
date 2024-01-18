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
	private static func normalizeLanguageName(_ identifier: String) -> String {
		identifier.lowercased().replacingOccurrences(of: "-", with: "_")
	}

	private static func languageDocumentType(from identifier: String) -> UTType {
		let name = Self.normalizeLanguageName(identifier)

		switch name {
		case "swift":
			return .swiftSource
		case "markdown":
			return .markdown
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

	public func languageConfiguration(with identifier: String) -> LanguageConfiguration? {
		let utType = LanguageDataStore.languageDocumentType(from: identifier)

		// shortcut this
		if utType == .plainText {
			return nil
		}

		if let value = configurationCache[utType] {
			return value
		}

		Task {
			_ = try await loadLanguageConfiguration(with: utType, identifier: identifier)
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
}
