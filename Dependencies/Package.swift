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
		.package(url: "https://github.com/mattmassicotte/tree-sitter-clojure", branch: "feature/spm"),
		.package(url: "https://github.com/elixir-lang/tree-sitter-elixir", branch: "main"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-go", branch: "master"),
		.package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown", branch: "split_parser"),
		.package(url: "https://github.com/tree-sitter/tree-sitter-ocaml", branch: "master"),
		.package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "with-generated-files"),
	],
	targets: [
		.target(
			name: "TreeSitterParsers",
			dependencies: [
				.product(name: "TreeSitterClojure", package: "tree-sitter-clojure"),
				.product(name: "TreeSitterElixir", package: "tree-sitter-elixir"),
				.product(name: "TreeSitterGo", package: "tree-sitter-go"),
				.product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
				.product(name: "TreeSitterOCaml", package: "tree-sitter-ocaml"),
				.product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
			]
		),
	]
)
