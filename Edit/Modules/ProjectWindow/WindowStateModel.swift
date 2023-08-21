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
	private var windowState = WindowStateObserver.State(window: nil)

	@ObservationIgnored
	private var activeSibling: WindowStateModel? {
		didSet { precondition(activeSibling !== self) }
	}

	@ObservationIgnored
	var siblingProvider: SiblingProvider = { [] }
	var currentTheme: Theme = Theme()
	var projectContext: ProjectContext? {
		didSet { projectContextUpdated() }
	}
	var documentContext: DocumentContext

	@ObservationIgnored
	let navigatorModel = FileNavigatorModel()

	init(documentContext: DocumentContext) {
		self.documentContext = documentContext
	}

	func windowStateChanged(_ old: WindowStateObserver.State, _ new: WindowStateObserver.State) {
		let keyOrMainChange = old.isKeyOrMain != new.isKeyOrMain

		if keyOrMainChange {
			synchronizeUI()
		}

		// we need to make sure that a window newly-brought to the foreground becomes the current UI
		// for any other windows, as their ref can get stale as windows close
		if new.isKeyOrMain {
			becomeActiveSibling()
		}

		self.windowState = new
	}
}

extension WindowStateModel {
	private func projectContextUpdated() {
		navigatorModel.root = projectContext.flatMap { NavigatorItem.file($0.url) } ?? .none

		self.activeSibling = frontmostSibling
	}

	private var siblings: [WindowStateModel] {
		siblingProvider()
	}

	private var frontmostSibling: WindowStateModel? {
		siblings
			.filter({ $0.windowState.isKeyOrMain })
			.first
	}

	func becomeActiveSibling() {
		// if neither of these hold, changes cannot be done by the user
		guard windowState.isKeyOrMain else {
			return
		}

		for sibling in siblings {
			sibling.activeSibling = self
		}
	}

	private func synchronizeUI() {
		print("syncing: ", self, " -> ", activeSibling)
	}
}
