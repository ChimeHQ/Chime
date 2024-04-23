import SwiftUI

import ChimeKit
import Diagnostics
import DocumentContent
import Navigator
import Theme
import ThemePark
import WindowTreatment
import Utility

@MainActor
@Observable
public final class WindowStateModel {
	typealias SiblingProvider = () -> [WindowStateModel]

	@ObservationIgnored
	private var windowState = WindowStateObserver.State(window: nil)

	@ObservationIgnored
	private var activeSibling: WindowStateModel? {
		didSet { precondition(activeSibling !== self) }
	}

	@ObservationIgnored
	var siblingProvider: SiblingProvider = { [] }

	@ObservationIgnored
	private let themeStore: ThemeStore

	/// It is really gross tha this is neeeded.
	@ObservationIgnored
	public var window: NSWindow? {
		didSet {
			themeChanged()
		}
	}

	@ObservationIgnored
	public var themeUpdated: (Theme) -> Void = { _ in }

	public private(set) var currentTheme: Theme
	var documentContext: DocumentContext

	var projectState: ProjectState? {
		didSet { stateUpdated() }
	}

	public init(context: DocumentContext, themeStore: ThemeStore) {
		self.documentContext = context
		self.themeStore = themeStore

		let theme = UserDefaults.standard
			.string(forKey: "theme-identifier")
			.map { themeStore.theme(with: $0) }

		self.currentTheme = theme ?? Theme.fallback
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

	func loadTheme(with identifier: String) {
		self.currentTheme = themeStore.theme(with: identifier)

		themeChanged()
	}

	private func themeChanged() {
		if let window {
			let effectiveAppearance = window.effectiveAppearance

			if currentTheme.supportedVariants.contains(.init(appearance: effectiveAppearance)) == false {
				window.appearance = currentTheme.supportedVariants.first?.appearance
			}
		}

		themeUpdated(currentTheme)
	}

	var navigatorModel: FileNavigatorModel {
		projectState?.navigatorModel ?? FileNavigatorModel()
	}

	var diagnosticsModel: DiagnosticsModel {
		projectState?.diagnosticsModel ?? DiagnosticsModel()
	}

	var projectContext: ProjectContext? {
		projectState?.context
	}

	var searchActive: Bool {
		false
	}
}

extension WindowStateModel {
	private func stateUpdated() {
		print("project state updated")
		projectContextUpdated()
	}

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
//		print("syncing: ", self, " -> ", activeSibling)
	}
}
