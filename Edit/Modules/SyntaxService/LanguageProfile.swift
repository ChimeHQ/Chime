import Foundation

import SwiftTreeSitter
import TextFormation

enum LanguageProfileError: Error {
	case treeSitterUnsupported
	case resourceURLMissing
}

public struct LanguageProfile {
	public let name: String
	public let language: SwiftTreeSitter.Language?
	public let bundleName: String?
	public let mutationFilter: NewFilter

	public init(name: String, language: SwiftTreeSitter.Language?, bundleName: String?, mutationFilter: NewFilter) {
		self.name = name
		self.language = language
		self.bundleName = bundleName
		self.mutationFilter = mutationFilter
	}

	public init(name: String, language: SwiftTreeSitter.Language?, mutationFilter: NewFilter) {
		let bundleName = "TreeSitter\(name)_TreeSitter\(name)"

		self.name = name
		self.language = language
		self.bundleName = bundleName
		self.mutationFilter = mutationFilter
	}

	public init(_ rootLanguage: RootLanguage, language: SwiftTreeSitter.Language?, mutationFilter: NewFilter) {
		let name = rootLanguage.rawValue
		let bundleName = "TreeSitter\(name)_TreeSitter\(name)"

		self.name = name
		self.language = language
		self.bundleName = bundleName
		self.mutationFilter = mutationFilter
	}
}

extension LanguageProfile {
	public nonisolated func loadLanguageConfiguration() async throws -> LanguageConfiguration {
		try load()
	}

	public func load() throws -> LanguageConfiguration {
		guard
			let language = language,
			let bundleName = bundleName
		else {
			throw LanguageProfileError.treeSitterUnsupported
		}

		let queryURL = try LanguageProfile.languageQueryDirectory(for: name, bundleName: bundleName)

		return try LanguageConfiguration(language, name: name, queriesURL: queryURL)
	}

	private static func languageQueryDirectory(for name: String, bundleName: String) throws -> URL {
		guard let resourceURL = Bundle(for: SyntaxService.self).resourceURL else {
			throw LanguageProfileError.resourceURLMissing
		}

		let builtInURL = resourceURL
			.appending(component: "LanguageData", directoryHint: .isDirectory)
			.appending(component: name, directoryHint: .isDirectory)
			.appending(component: "queries", directoryHint: .isDirectory)
			.standardizedFileURL

		if FileManager.default.isReadableFile(atPath: builtInURL.path(percentEncoded: false)) {
			return builtInURL
		}

		let bundleComponent = bundleName + ".bundle"
		
		guard let mainResourceURL = Bundle.main.resourceURL else {
			throw LanguageProfileError.resourceURLMissing
		}

		return mainResourceURL
			.appending(component: bundleComponent, directoryHint: .isDirectory)
			.appending(component: "Contents/Resources/queries", directoryHint: .isDirectory)
	}
}

