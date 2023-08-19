import SwiftUI

import ChimeKit
import Navigator
import Theme
import WindowTreatment

@MainActor
@Observable
final class WindowStateModel {
	typealias SiblingProvider = () -> [WindowStateModel]

	@ObservationIgnored
	var siblingProvider: SiblingProvider = { [] }
	var currentTheme: Theme = Theme()
	var projectContext: ProjectContext? {
		didSet {
			navigatorModel.root = projectContext.flatMap { NavigatorItem.file($0.url) } ?? .none
		}
	}
	var documentContext: DocumentContext

	@ObservationIgnored
	let navigatorModel = FileNavigatorModel()

	init(documentContext: DocumentContext) {
		self.documentContext = documentContext
	}

	func windowStateChanged(_ old: WindowStateObserver.State, _ new: WindowStateObserver.State) {
//		print("siblings: \(siblingProvider())")
	}
}
