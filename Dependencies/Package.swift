// swift-tools-version: 5.10

import PackageDescription

// This package defines all of the SPM dependencies for the project. It is used as an alternative to the Xcode SPM dependency editor.
// I have not yet migrated everything in here.

let package = Package(
	name: "Dependencies",
	platforms: [
		.macOS(.v14),
		.macCatalyst(.v16),
		.iOS(.v16),
		.visionOS(.v1),
	],
	products: [
		// I don't think many dependencies will need to use this same approach.
		.library(name: "TreeSitterParsers", targets: ["TreeSitterParsers"]),
		.library(name: "Dependencies", targets: ["Dependencies"])
	],
	dependencies: [
		.package(url: "https://github.com/tree-sitter/tree-sitter-bash", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-c", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-css", branch: "master"),
		.package(url: "https://github.com/mattmassicotte/tree-sitter-clojure", branch: "feature/spm"),
		.package(url: "https://github.com/elixir-lang/tree-sitter-elixir", branch: "main"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-html", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-go", branch: "master"),
		.package(url: "https://github.com/camdencheek/tree-sitter-go-mod", branch: "main"),
		.package(url: "https://github.com/tree-sitter-grammars/tree-sitter-go-sum", branch: "master"),
		.package(url: "https://github.com/mattmassicotte/tree-sitter-go-work", branch: "feature/spm"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-javascript", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-json", branch: "master"),
		.package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown", branch: "split_parser"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-ocaml", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-python", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-ruby", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-rust", branch: "master"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-typescript", branch: "master"),
		.package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "with-generated-files"),

		// this has to match what is in Ligature, for now
		.package(url: "https://github.com/ChimeHQ/Glyph", revision: "63cc672cd1bcc408b3a5158816985c82308e5f83"),
		.package(url: "https://github.com/ChimeHQ/IBeam", revision: "53e0ea98ce3fa299ebbd76bd7b17c561908c763c"),
		.package(url: "https://github.com/ChimeHQ/Ligature", revision: "a43d576b2f453f91c8a55f73f4eecd5ec4425ea2"),
		.package(url: "https://github.com/ChimeHQ/SourceView", revision: "3464fd06c2edf97d4df285039141fa4c6ce7eaf0"),
		.package(url: "https://github.com/ChimeHQ/TextFormation", branch: "feature/process-mutation")
	],
	targets: [
		.target(
			name: "TreeSitterParsers",
			dependencies: [
				.product(name: "TreeSitterBash", package: "tree-sitter-bash"),
				.product(name: "TreeSitterC", package: "tree-sitter-c"),
				.product(name: "TreeSitterCSS", package: "tree-sitter-css"),
				.product(name: "TreeSitterClojure", package: "tree-sitter-clojure"),
				.product(name: "TreeSitterElixir", package: "tree-sitter-elixir"),
				.product(name: "TreeSitterGo", package: "tree-sitter-go"),
				.product(name: "TreeSitterGoMod", package: "tree-sitter-go-mod"),
				.product(name: "TreeSitterGosum", package: "tree-sitter-go-sum"),
				.product(name: "TreeSitterGoWork", package: "tree-sitter-go-work"),
				.product(name: "TreeSitterHTML", package: "tree-sitter-html"),
				.product(name: "TreeSitterJavaScript", package: "tree-sitter-javascript"),
				.product(name: "TreeSitterJSON", package: "tree-sitter-json"),
				.product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
				.product(name: "TreeSitterOCaml", package: "tree-sitter-ocaml"),
				.product(name: "TreeSitterPython", package: "tree-sitter-python"),
				.product(name: "TreeSitterRuby", package: "tree-sitter-ruby"),
				.product(name: "TreeSitterRust", package: "tree-sitter-rust"),
				.product(name: "TreeSitterTypeScript", package: "tree-sitter-typescript"),
				.product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
			]
		),
		.target(
			name: "Dependencies",
			dependencies: [
				"Glyph",
				"IBeam",
				"Ligature",
				"SourceView",
				"TextFormation",
			]
		),
	]
)
