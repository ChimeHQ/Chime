import AppKit
import SwiftUI

import UIUtility

public final class ProjectWindowController: NSWindowController {
	public init(contentViewController: NSViewController) {
		let representedController = RepresentableViewController(contentViewController)
		let rootView = ProjectWindowRootView(content: { representedController })
		let window = NSWindow(contentViewController: NSHostingController(rootView: rootView))

		// Only explicitly enable this if the document's project gets set. This prevents accidentally getting into tab mode for a single file.
		window.tabbingMode = .disallowed
		window.isExcludedFromWindowsMenu = true

		super.init(window: window)
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
