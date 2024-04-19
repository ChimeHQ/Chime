import Foundation

import ChimeKit
import Diagnostics
import Navigator

@MainActor
public struct ProjectState {
	public let context: ProjectContext
	public let navigatorModel = FileNavigatorModel()
	public let diagnosticsModel = DiagnosticsModel()

	public init(context: ProjectContext) {
		self.context = context
	}

	public init(url: URL) {
		self.init(context: ProjectContext(url: url))
	}

	public func updateDiagnostics(_ docDiagnostics: DocumentDiagnostics) {
		diagnosticsModel.updateDiagnostics(docDiagnostics)
	}
}
