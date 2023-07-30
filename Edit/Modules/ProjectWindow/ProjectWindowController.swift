import AppKit
import SwiftUI

import UIUtility
import WindowTreatment

public final class ProjectWindowController: NSWindowController {
	private let syncModel = WindowStateSynchronizationModel()

	public init(contentViewController: NSViewController) {
		// we know that our initial core view requires AppKit...
		let representedController = RepresentableViewController(contentViewController)

		// but we want to manage as much as possible with SwiftUI here...
		let rootView = ProjectWindowRoot(content: { representedController })
			.environment(syncModel)
			.observeWindowState()

		// and then get it all back into the NSWindow
		let hostingController = NSHostingController(rootView: rootView)
		let window = NSWindow(contentViewController: hostingController)

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
}

extension ProjectWindowController: NSWindowDelegate {
	public func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		(document as? NSDocument)?.undoManager
	}
}

extension ProjectWindowController {
	private var siblingModels: [WindowStateSynchronizationModel] {
		let siblingWindows = window?.tabGroup?.windows.filter({ $0 !== window }) ?? []
		let siblingControllers = siblingWindows.compactMap { $0.windowController as? ProjectWindowController }

		return siblingControllers.map { $0.syncModel }
	}
}
