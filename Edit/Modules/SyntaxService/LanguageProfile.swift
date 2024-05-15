import Foundation

import SwiftTreeSitter

enum LanguageProfileError: Error {
	case treeSitterUnsupported
	case resourceURLMissing
}

public struct LanguageProfile: Sendable {
	public let name: String
	public let language: SwiftTreeSitter.Language?
	public let bundleName: String?

	public init(name: String, language: SwiftTreeSitter.Language?, bundleName: String?) {
		self.name = name
		self.language = language
		self.bundleName = bundleName
	}

	public init(name: String, language: SwiftTreeSitter.Language?) {
		let bundleName = "TreeSitter\(name)_TreeSitter\(name)"

		self.name = name
		self.language = language
		self.bundleName = bundleName
	}

	public init(_ rootLanguage: RootLanguage, language: SwiftTreeSitter.Language?) {
		let name = rootLanguage.rawValue
		let bundleName = "TreeSitter\(name)_TreeSitter\(name)"

		self.name = name
		self.language = language
		self.bundleName = bundleName
	}
}

extension LanguageProfile {
	public func loadLanguageConfiguration() async throws -> LanguageConfiguration {
		try await withUnsafeThrowingContinuation { continuation in
			DispatchQueue.global().async {
				let result = Result(catching: { try load() })

				continuation.resume(with: result)
			}
		}
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
