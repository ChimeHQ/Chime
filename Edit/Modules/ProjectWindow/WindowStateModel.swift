import SwiftUI

import ChimeKit
import Theme
import WindowTreatment

@Observable
final class WindowStateModel {
	typealias SiblingProvider = () -> [WindowStateModel]

	@ObservationIgnored
	var siblingProvider: SiblingProvider = { [] }
	var currentTheme: Theme = Theme()
	var projectContext: ProjectContext?
	var documentContext: DocumentContext
	var appeared = false

	init(documentContext: DocumentContext) {
		self.documentContext = documentContext
	}

	func windowStateChanged(_ old: WindowStateObserver.State, _ new: WindowStateObserver.State) {
//		print("siblings: \(siblingProvider())")
	}
}
