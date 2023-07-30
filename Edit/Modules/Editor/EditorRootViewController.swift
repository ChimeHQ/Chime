import AppKit
import SwiftUI

import Inspector
import Navigator
import Search

/// Defines the overall editor scene.
///
/// This controller establishes the larger editor scene, typing together the sub components.
public final class EditorRootViewController: NSViewController {
	let controller = NSSplitViewController()
	let searchBarHostView = NSHostingView(rootView: SearchBar())

	public init() {
		super.init(nibName: nil, bundle: nil)
	}


	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		let navigatorHost = NSHostingController(rootView: Navigator())
		let navigatorItem = NSSplitViewItem(sidebarWithViewController: navigatorHost)

		let sourceHost = NSHostingController(rootView: SourceRootView())
		let editorItem = NSSplitViewItem(viewController: sourceHost)

		let inspectorHost = NSHostingController(rootView: Inspector())
		let inspectorItem = NSSplitViewItem(viewController: inspectorHost)

		controller.splitViewItems = [navigatorItem, editorItem, inspectorItem]

		self.view = NSView()

		view.subviews = [controller.view, searchBarHostView]
		searchBarHostView.translatesAutoresizingMaskIntoConstraints = false
		controller.view.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			searchBarHostView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			searchBarHostView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			searchBarHostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

			controller.view.topAnchor.constraint(equalTo: view.topAnchor),
			controller.view.bottomAnchor.constraint(equalTo: searchBarHostView.topAnchor),
			controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
		])
	}
}
