import Foundation

import SwiftTreeSitter
import UniformTypeIdentifiers

import TreeSitterGo
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift

extension LanguageProfile {
	static func profile(for utType: UTType) -> LanguageProfile {
		if utType.conforms(to: .markdown) {
			return LanguageProfile.markdownProfile
		}

		if utType.conforms(to: .markdownInline) {
			return LanguageProfile.markdownInlineProfile
		}

		if utType.conforms(to: .swiftSource) {
			return LanguageProfile.swiftProfile
		}

		if utType.conforms(to: .goSource) {
			return LanguageProfile.goProfile
		}

		return LanguageProfile.genericProfile
	}
}

extension LanguageProfile {
	static let goProfile = LanguageProfile(
		name: "Go",
		language: Language(tree_sitter_go())
	)

	static let markdownProfile = LanguageProfile(
		name: "Markdown",
		language: Language(tree_sitter_markdown())
	)

	static let markdownInlineProfile = LanguageProfile(
		name: "MarkdownInline",
		language: Language(tree_sitter_markdown_inline()),
		bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
	)

	static let swiftProfile = LanguageProfile(
		name: "Swift",
		language: Language(tree_sitter_swift())
	)

	static let genericProfile = LanguageProfile(
		name: "generic",
		language: nil,
		bundleName: nil
	)
}
