import AppKit
import SwiftUI

import ChimeKit
import Theme
import UIUtility
import WindowTreatment

public final class ProjectWindowController: NSWindowController {
	private let model: WindowStateModel

	public init(contentViewController: NSViewController, documentContext: DocumentContext) {
		let syncModel = WindowStateModel(documentContext: documentContext)

		let contentController = ProjectContentViewController(contentViewController: contentViewController)

		// Kind of a lot going on here. Want to manage a bunch of stuff from SwiftUI, but have to estalish our context here so we can get window state and the syncing model into the root.
		let controller = RepresentableViewController.wrap(controller: contentController) { view in
			ProjectWindowRoot {
				view
			}
			.environment(syncModel)
			.observeWindowState()
		}

		self.model = syncModel

		let window = NSWindow(contentViewController: controller)

		window.titlebarAppearsTransparent = true
		window.styleMask.insert(.fullSizeContentView)

		super.init(window: window)

		window.tabbingMode = .preferred
		window.tabbingIdentifier = "hello"

		syncModel.siblingProvider = { [weak self] in self?.siblingModels ?? [] }
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public var projectContext: ProjectContext? {
		get { model.projectContext }
		set { model.projectContext = newValue }
	}

	public var documentContext: DocumentContext {
		get { model.documentContext }
		set { model.documentContext = newValue }
	}
}

extension ProjectWindowController: NSWindowDelegate {
	public func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		(document as? NSDocument)?.undoManager
	}
}

extension ProjectWindowController {
	private var siblingModels: [WindowStateModel] {
		let siblingWindows = window?.tabGroup?.windows.filter({ $0 !== window }) ?? []
		let siblingControllers = siblingWindows.compactMap { $0.windowController as? ProjectWindowController }

		return siblingControllers.map { $0.model }
	}
}
