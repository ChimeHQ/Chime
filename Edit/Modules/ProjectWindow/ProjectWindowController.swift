import AppKit
import SwiftUI

import ChimeKit
import DocumentContent
import Navigator
import OpenQuickly
import Theme
import UIUtility
import WindowTreatment

public final class ProjectWindowController: NSWindowController {
	public typealias SiblingProvider = () -> [ProjectWindowController]
	public typealias OnOpen = (URL) -> Void

	private let model: WindowStateModel
	private let siblingProvider: SiblingProvider

    private lazy var openQuicklyWindowController: OpenQuicklyWindowController = {
        let rootURL = self.model.projectContext?.url
        let context = OpenQuicklyContext(
            rootURL: rootURL,
            selectionHandler: { print("item selected: \($0)") }
        )

        return OpenQuicklyWindowController(context: context, symbolQueryService: nil)
    }()

	public init(
		contentViewController: NSViewController,
		model: WindowStateModel,
		siblingProvider: @escaping SiblingProvider,
		onOpen: @escaping OnOpen
	) {

		let contentController = ProjectContentViewController(contentViewController: contentViewController)

		// Kind of a lot going on here. Want to manage a bunch of stuff from SwiftUI, but have to establish our context here so we can get window state and the syncing model into the root.
		let controller = RepresentableViewController.wrap(controller: contentController) { view in
			ProjectWindowRoot {
				view
			}
			.environment(model)
			.environment(\.openURL, OpenURLAction { url in
				onOpen(url)
				
				return .handled
			})
			.observeWindowState()
		}

		self.siblingProvider = siblingProvider
		self.model = model

		let window = TitlebarClickAwareWindow(contentViewController: controller)

		window.titlebarAppearsTransparent = true
		window.styleMask.insert(.fullSizeContentView)

		super.init(window: window)

		model.window = window
		window.tabbingMode = .preferred
		window.tabbingIdentifier = "hello"

		model.siblingProvider = { [weak self] in self?.siblingModels ?? [] }
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var state: ProjectState? {
		get { model.projectState }
		set { model.projectState = newValue }
	}

	public var symbolQueryService: SymbolQueryService? {
		get { openQuicklyWindowController.symbolQueryService }
		set { openQuicklyWindowController.symbolQueryService = newValue }
	}
}

extension ProjectWindowController: NSWindowDelegate {
	public func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		(document as? NSDocument)?.undoManager
	}
}

extension ProjectWindowController {
	/// Return all sibling models for this project group.
	///
	/// I tried to use window?.tabGroup do to this, and it was really tempting. I was never able to get it to work right, because just accessing the tabGroup property of a window affects its tabbing behavior.
	private var siblingModels: [WindowStateModel] {
//		let siblingWindows = window?.tabGroup?.windows.filter({ $0 !== window }) ?? []
		let siblingControllers = siblingProvider()

		return siblingControllers.map { $0.model }
	}
}

extension ProjectWindowController {
    @IBAction func openQuickly(_ sender: Any?) {
        guard let window = window else { preconditionFailure() }

        openQuicklyWindowController.showWindow(parent: window)
    }
}
