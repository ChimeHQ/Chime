import Foundation

import SwiftTreeSitter
import UniformTypeIdentifiers
import TreeSitterParsers
import TextFormation

import TreeSitterSwift

@MainActor
extension LanguageProfile {
	static func profile(for utType: UTType) -> LanguageProfile {
		if utType.conforms(to: .shellScript) {
			return LanguageProfile.bashProfile
		}

		if utType.conforms(to: .cSource) || utType.conforms(to: .cHeader) {
			return LanguageProfile.cProfile
		}
		
		if utType.conforms(to: .cssSource)  {
			return LanguageProfile.cssProfile
		}

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

		if utType.conforms(to: .html) {
			return LanguageProfile.htmlProfile
		}

		if utType.conforms(to: .javaScript) {
			return LanguageProfile.javaScriptProfile
		}

		if utType.conforms(to: .json) {
			return LanguageProfile.jsonProfile
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

		if utType.conforms(to: .rubyScript) {
			return LanguageProfile.rubyProfile
		}
		
		if utType.conforms(to: .rustSource) {
			return LanguageProfile.rustProfile
		}

		if utType.conforms(to: .swiftSource) {
			return LanguageProfile.swiftProfile
		}

		// special-case this type to allow the same extension to be used by default
		if utType.conforms(to: .typescriptSource) || utType.conforms(to: .mpeg2TransportStream) {
			return LanguageProfile.typeScriptProfile
		}

		return LanguageProfile.genericProfile
	}

	private static let genericFilter: NewFilter = {
		let deleteCloseFilter = NewDeleteCloseFilter(open: "(", close: ")")
		let newlineFilter = NewNewlineProcessingFilter()

		return NewCompositeFilter(filters: [deleteCloseFilter, newlineFilter])
	}()

	static let bashProfile = LanguageProfile(
		RootLanguage.bash,
		language: Language(tree_sitter_bash()),
		mutationFilter: genericFilter
	)

	static let cProfile = LanguageProfile(
		RootLanguage.c,
		language: Language(tree_sitter_c()),
		mutationFilter: genericFilter
	)

	static let cssProfile = LanguageProfile(
		RootLanguage.css,
		language: Language(tree_sitter_css()),
		mutationFilter: genericFilter
	)

	static let clojureProfile = LanguageProfile(
		RootLanguage.clojure,
		language: Language(tree_sitter_clojure()),
		mutationFilter: genericFilter
	)

	static let elixirProfile = LanguageProfile(
		RootLanguage.elixir,
		language: Language(tree_sitter_elixir()),
		mutationFilter: genericFilter
	)

	static let goProfile = LanguageProfile(
		RootLanguage.go,
		language: Language(tree_sitter_go()),
		mutationFilter: genericFilter
	)

	static let goModProfile = LanguageProfile(
		RootLanguage.goMod,
		language: Language(tree_sitter_gomod()),
		mutationFilter: genericFilter
	)

	static let goSumProfile = LanguageProfile(
		RootLanguage.goSum,
		language: Language(tree_sitter_gosum()),
		mutationFilter: genericFilter
	)

	static let goWorkProfile = LanguageProfile(
		RootLanguage.goWork,
		language: Language(tree_sitter_gowork()),
		mutationFilter: genericFilter
	)

	static let htmlProfile = LanguageProfile(
		RootLanguage.html,
		language: Language(tree_sitter_html()),
		mutationFilter: genericFilter
	)

	static let javaScriptProfile = LanguageProfile(
		RootLanguage.javaScript,
		language: Language(tree_sitter_javascript()),
		mutationFilter: genericFilter
	)

	static let jsonProfile = LanguageProfile(
		RootLanguage.json,
		language: Language(tree_sitter_json()),
		mutationFilter: genericFilter
	)

	static let markdownProfile = LanguageProfile(
		RootLanguage.markdown,
		language: Language(tree_sitter_markdown()),
		mutationFilter: genericFilter
	)

	static let markdownInlineProfile = LanguageProfile(
		name: "MarkdownInline",
		language: Language(tree_sitter_markdown_inline()),
//		bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline",
		mutationFilter: genericFilter
	)

	static let ocamlProfile = LanguageProfile(
		RootLanguage.ocaml,
		language: Language(tree_sitter_ocaml()),
		mutationFilter: genericFilter
	)

	static let ocamlInterfaceProfile = LanguageProfile(
		name: "OCaml Interface",
		language: Language(tree_sitter_ocaml_interface()),
		bundleName: "TreeSitterOCaml_TreeSitterOCaml",
		mutationFilter: genericFilter
	)

	static let pythonProfile = LanguageProfile(
		RootLanguage.python,
		language: Language(tree_sitter_python()),
		mutationFilter: genericFilter
	)

	static let rubyProfile = LanguageProfile(
		RootLanguage.ruby,
		language: Language(tree_sitter_ruby()),
		mutationFilter: genericFilter
	)

	static let rustProfile = LanguageProfile(
		RootLanguage.rust,
		language: Language(tree_sitter_rust()),
		mutationFilter: genericFilter
	)

	static let swiftProfile = LanguageProfile(
		RootLanguage.swift,
		language: Language(tree_sitter_swift()),
		mutationFilter: genericFilter
	)

	static let typeScriptProfile = LanguageProfile(
		RootLanguage.typeScript,
		language: Language(tree_sitter_typescript()),
		mutationFilter: genericFilter
	)

	static let genericProfile = LanguageProfile(
		name: "generic",
		language: nil,
		bundleName: nil,
		mutationFilter: genericFilter
	)
}
