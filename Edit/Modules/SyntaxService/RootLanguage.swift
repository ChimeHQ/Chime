import Foundation
import UniformTypeIdentifiers

import ChimeKit

/// Describes a document root language.
///
/// This type must also be compiled into EditIntents, because the AppIntent infrastructure depends on having the type visible within the module.
public enum RootLanguage: Hashable, CaseIterable, Sendable {
	case clojure
	case go
	case markdown
	case ocaml
	case ocamlInterface
	case swift

	var typeIdentifier: UTType {
		switch self {
		case .clojure: .clojureSource
		case .go: .goSource
		case .markdown: .markdown
		case .ocaml: .ocamlSource
		case .ocamlInterface: .ocamlInterface
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
		case "go":
			self = .go
		case "markdown":
			self = .markdown
		case "ocaml":
			self = .ocaml
		case "ocaml-interface":
			self = .ocamlInterface
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
		case .go:
			"Go"
		case .markdown:
			"Markdown"
		case .ocaml:
			"OCaml"
		case .ocamlInterface:
			"OCaml Interface"
		case .swift:
			"Swift"
		}
	}
}
