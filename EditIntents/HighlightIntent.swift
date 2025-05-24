import AppIntents

import Neon
import SyntaxService
import Theme
import TreeSitterClient
import UniformTypeIdentifiers

extension RootLanguage: AppEnum {
	public static var typeDisplayRepresentation: TypeDisplayRepresentation { "Language" }
	public static var caseDisplayRepresentations: [RootLanguage: DisplayRepresentation] {
		[
			.bash: "Bash",
			.c: "C",
			.css: "CSS",
			.clojure: "Clojure",
			.elixir: "Elixir",
			.go: "Go",
			.goMod: "Go Mod",
			.goSum: "Go Sum",
			.goWork: "Go Work",
			.html: "HTML",
			.javaScript: "JavaScript",
			.json: "JSON",
			.markdown: "Markdown",
			.ocaml: "OCaml",
			.ocamlInterface: "OCaml Interface",
			.python: "Python",
			.ruby: "Ruby",
			.rust: "Rust",
			.swift: "Swift",
			.typeScript: "TypeScript",
		]
	}
}

enum HighlightIntentError: Error {
	case languageConfigurationUnavailable
}

struct HighlightIntent: AppIntent {
	nonisolated static let title: LocalizedStringResource = "Highlight Source Code"
	static var description: IntentDescription { "Applies syntax highlighting to the input." }
	nonisolated static let openAppWhenRun = false

	@Parameter(title: "Source", description: "The source code to be highlighted", inputConnectionBehavior: .connectToPreviousIntentResult)
	var source: String

	@Parameter(title: "Language")
	var language: RootLanguage

	nonisolated static var parameterSummary: some ParameterSummary {
		Summary("Highlight \(\.$language) source code.")
	}

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<AttributedString> {
		let theme = ThemeStore.currentTheme ?? Theme.fallback
		let store = LanguageDataStore()
		guard let rootConfig = try await store.loadLanguageConfiguration(with: language.typeIdentifier) else {
			throw HighlightIntentError.languageConfigurationUnavailable
		}

		let context = Query.Context(controlState: .active, variant: .init(colorScheme: .dark, colorSchemeContrast: .standard))

		let attrProvider: TokenAttributeProvider = { token in
			let style = theme.highlightsQueryCaptureStyle(for: token.name, context: context)

			return [.foregroundColor: style.color]
		}

		let highlightedSource = try await TreeSitterClient.highlight(
			string: source,
			attributeProvider: attrProvider,
			rootLanguageConfig: rootConfig,
			languageProvider: { store.languageConfiguration(with: $0, background: false) }
		)

		return .result(value: highlightedSource)
	}
}
