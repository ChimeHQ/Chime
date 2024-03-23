import AppKit
import SwiftUI

import Inspector
import Navigator

final class ProjectContentViewController: NSViewController {
	private let splitViewController = NSSplitViewController()
	private let contentViewController: NSViewController
	private let inspectorItem: NSSplitViewItem

	init(contentViewController: NSViewController) {
		self.contentViewController = contentViewController

		let inspectorHost = NSHostingController(rootView: Inspector())
		self.inspectorItem = NSSplitViewItem(viewController: inspectorHost)

		super.init(nibName: nil, bundle: nil)

		addChild(splitViewController)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let navigatorHost = NSHostingController(rootView: Navigator())
		let navigatorItem = NSSplitViewItem(sidebarWithViewController: navigatorHost)

		// temporarily hide the navigator by default, until it gets a little more attention
		navigatorItem.isCollapsed = true

		inspectorItem.minimumThickness = 140
		inspectorItem.canCollapse = true
		inspectorItem.isCollapsed = true

		let editorItem = NSSplitViewItem(viewController: contentViewController)
		editorItem.minimumThickness = 200

		splitViewController.splitViewItems = [navigatorItem, editorItem, inspectorItem]

		self.view = NSView()

		view.subviews = [splitViewController.view]

		splitViewController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			splitViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
			splitViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			splitViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			splitViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
}

extension ProjectContentViewController {
	@IBAction
	func toggleExtensionInspector(_ sender: Any?) {
		let collaspe = inspectorItem.isCollapsed == false

		inspectorItem.animator().isCollapsed = collaspe
	}
}
