import Foundation

import SwiftTreeSitter
import UniformTypeIdentifiers
import TreeSitterParsers

import TreeSitterSwift

extension LanguageProfile {
	static func profile(for utType: UTType) -> LanguageProfile {
		if utType.conforms(to: .clojureSource) {
			return LanguageProfile.clojureProfile
		}

		if utType.conforms(to: .elixirSource) {
			return LanguageProfile.elixirProfile
		}

		if utType.conforms(to: .goSource) {
			return LanguageProfile.goProfile
		}

		if utType.conforms(to: .goSumFile) {
			return LanguageProfile.goSumProfile
		}

		if utType.conforms(to: .markdown) {
			return LanguageProfile.markdownProfile
		}

		if utType.conforms(to: .markdownInline) {
			return LanguageProfile.markdownInlineProfile
		}

		if utType.conforms(to: .ocamlSource) {
			return LanguageProfile.ocamlProfile
		}

		if utType.conforms(to: .ocamlInterface) {
			return LanguageProfile.ocamlInterfaceProfile
		}

		if utType.conforms(to: .pythonScript) {
			return LanguageProfile.pythonProfile
		}

		if utType.conforms(to: .swiftSource) {
			return LanguageProfile.swiftProfile
		}

		return LanguageProfile.genericProfile
	}
}

extension LanguageProfile {
	static let clojureProfile = LanguageProfile(
		RootLanguage.clojure,
		language: Language(tree_sitter_clojure())
	)

	static let elixirProfile = LanguageProfile(
		RootLanguage.elixir,
		language: Language(tree_sitter_elixir())
	)

	static let goProfile = LanguageProfile(
		RootLanguage.go,
		language: Language(tree_sitter_go())
	)

	static let goModProfile = LanguageProfile(
		RootLanguage.goMod,
		language: Language(tree_sitter_gomod())
	)

	static let goSumProfile = LanguageProfile(
		RootLanguage.goSum,
		language: Language(tree_sitter_gosum())
	)

	static let goWorkProfile = LanguageProfile(
		RootLanguage.goWork,
		language: Language(tree_sitter_gowork())
	)

	static let markdownProfile = LanguageProfile(
		RootLanguage.markdown,
		language: Language(tree_sitter_markdown())
	)

	static let markdownInlineProfile = LanguageProfile(
		name: "MarkdownInline",
		language: Language(tree_sitter_markdown_inline()),
		bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
	)

	static let ocamlProfile = LanguageProfile(
		RootLanguage.ocaml,
		language: Language(tree_sitter_ocaml())
	)

	static let ocamlInterfaceProfile = LanguageProfile(
		name: "OCaml Interface",
		language: Language(tree_sitter_ocaml_interface()),
		bundleName: "TreeSitterOCaml_TreeSitterOCaml"
	)

	static let pythonProfile = LanguageProfile(
		RootLanguage.python,
		language: Language(tree_sitter_python())
	)

	static let swiftProfile = LanguageProfile(
		RootLanguage.swift,
		language: Language(tree_sitter_swift())
	)

	static let genericProfile = LanguageProfile(
		name: "generic",
		language: nil,
		bundleName: nil
	)
}
