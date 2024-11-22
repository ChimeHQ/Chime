// swift-tools-version: 5.10

import PackageDescription

// This package defines all of the SPM dependencies for the project. It is used as an alternative to the Xcode SPM dependency editor.
// I have not yet migrated everything in here.

let package = Package(
	name: "Dependencies",
	products: [
		// I don't think many dependencies will need to use this same approach.
		.library(name: "TreeSitterParsers", targets: ["TreeSitterParsers"]),
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
		.package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "with-generated-files"),
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
				.product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
			]
		),
	]
)
