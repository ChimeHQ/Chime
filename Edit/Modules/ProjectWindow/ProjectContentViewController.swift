import AppKit
import SwiftUI

import Inspector
import Navigator

final class ProjectContentViewController: NSViewController {
	private let controller = NSSplitViewController()
	private let contentViewController: NSViewController

	init(contentViewController: NSViewController) {
		self.contentViewController = contentViewController

		super.init(nibName: nil, bundle: nil)

		addChild(controller)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let navigatorHost = NSHostingController(rootView: Navigator())
		let navigatorItem = NSSplitViewItem(sidebarWithViewController: navigatorHost)

		let inspectorHost = NSHostingController(rootView: Inspector())
		let inspectorItem = NSSplitViewItem(viewController: inspectorHost)
		inspectorItem.minimumThickness = 140
		inspectorItem.canCollapse = true

		let editorItem = NSSplitViewItem(viewController: contentViewController)
		editorItem.minimumThickness = 200

		controller.splitViewItems = [navigatorItem, editorItem, inspectorItem]

		self.view = NSView()

		view.subviews = [controller.view]

		controller.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			controller.view.topAnchor.constraint(equalTo: view.topAnchor),
			controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
}
