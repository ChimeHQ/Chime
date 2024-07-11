import Foundation
import UniformTypeIdentifiers

import ChimeKit

/// Describes a document root language.
///
/// This type must also be compiled into EditIntents, because the AppIntent infrastructure depends on having the type visible within the module.
public enum RootLanguage: Hashable, CaseIterable, Sendable {
	case clojure
	case elixir
	case go
	case goMod
	case goSum
	case goWork
	case markdown
	case ocaml
	case ocamlInterface
	case python
	case ruby
	case rust
	case swift

	var typeIdentifier: UTType {
		switch self {
		case .clojure: .clojureSource
		case .elixir: .elixirSource
		case .go: .goSource
		case .goMod: .goModFile
		case .goSum: .goSumFile
		case .goWork: .goWorkFile
		case .markdown: .markdown
		case .ocaml: .ocamlSource
		case .ocamlInterface: .ocamlInterface
		case .python: .pythonScript
		case .ruby: .rubyScript
		case .rust: .rustSource
		case .swift: .swiftSource
		}
	}
}

extension RootLanguage: RawRepresentable {
	public static func normalizeLanguageName(_ identifier: String) -> String {
		identifier.lowercased().replacingOccurrences(of: "-", with: "_")
	}

	public init?(rawValue: String) {
		switch Self.normalizeLanguageName(rawValue) {
		case "clojure":
			self = .clojure
		case "elixir":
			self = .elixir
		case "go":
			self = .go
		case "gomod":
			self = .goMod
		case "gosum":
			self = .goSum
		case "gowork":
			self = .goWork
		case "markdown":
			self = .markdown
		case "ocaml":
			self = .ocaml
		case "ocaml-interface":
			self = .ocamlInterface
		case "python":
			self = .python
		case "ruby":
			self = .ruby
		case "rust":
			self = .rust
		case "swift":
			self = .swift
		default:
			return nil
		}
	}

	public var rawValue: String {
		switch self {
		case .clojure:
			"Clojure"
		case .elixir:
			"Elixir"
		case .go:
			"Go"
		case .goMod:
			"Go Mod"
		case .goSum:
			"Go Sum"
		case .goWork:
			"Go Work"
		case .markdown:
			"Markdown"
		case .ocaml:
			"OCaml"
		case .ocamlInterface:
			"OCaml Interface"
		case .python:
			"Python"
		case .ruby:
			"Ruby"
		case .rust:
			"Rust"
		case .swift:
			"Swift"
		}
	}
}
