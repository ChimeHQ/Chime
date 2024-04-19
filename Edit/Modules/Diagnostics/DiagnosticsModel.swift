import Foundation

import ChimeKit

public struct DocumentDiagnostics: Hashable, Sendable {
	public let version: Int?
	public let url: URL
	public let diagnostics: [Diagnostic]

	public init(version: Int?, url: URL, diagnostics: [Diagnostic]) {
		self.version = version
		self.url = url
		self.diagnostics = diagnostics
	}

	var errors: [Diagnostic] {
		diagnostics.filter({ $0.kind == .error })
	}

	var warnings: [Diagnostic] {
		diagnostics.filter({ $0.kind == .warning })
	}

	var infos: [Diagnostic] {
		diagnostics.filter({ $0.kind == .hint || $0.kind == .information })
	}
}

@MainActor
@Observable
public final class DiagnosticsModel {
	public private(set) var documentDiagnostics: [URL: DocumentDiagnostics] = [:]

	public init() {

	}

	public func updateDiagnostics(_ docDiagnostics: DocumentDiagnostics) {
		let url = docDiagnostics.url

		self.documentDiagnostics[url] = docDiagnostics
	}

	public var hasDiagnostics: Bool {
		documentDiagnostics.contains(where: { $1.diagnostics.isEmpty == false })
	}

	public var errorCount: Int {
		documentDiagnostics.reduce(0, { $0 + $1.value.errors.count })
	}

	public var warningCount: Int {
		documentDiagnostics.reduce(0, { $0 + $1.value.warnings.count })
	}

	public var infoCount: Int {
		documentDiagnostics.reduce(0, { $0 + $1.value.warnings.count })
	}
}
