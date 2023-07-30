import AppKit
import SwiftUI

import Inspector
import Navigator
import Search
import UIUtility

/// Defines the overall editor scene.
///
/// This controller establishes the larger editor scene, typing together the sub components.
public final class EditorRootViewController: NSViewController {
	let controller = NSSplitViewController()
	let searchBarHostView = NSHostingView(rootView: SearchBar())
	let editorScrollView = NSScrollView()

	public init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		editorScrollView.hasVerticalScroller = true
		editorScrollView.hasHorizontalScroller = true
		editorScrollView.drawsBackground = true
		editorScrollView.backgroundColor = .black
		editorScrollView.automaticallyAdjustsContentInsets = false

		let navigatorHost = NSHostingController(rootView: Navigator())
		let navigatorItem = NSSplitViewItem(sidebarWithViewController: navigatorHost)

		let presentationController = SourcePresentationViewController(scrollView: editorScrollView)

		let phonyDocView = VStack(spacing: 0.0) {
			Rectangle()
				.foregroundStyle(.blue)
				.frame(height: 10.0)
			Color.orange
			Rectangle()
				.foregroundStyle(.red)
				.frame(height: 10.0)
		}
			.frame(minWidth: 300, minHeight: 300)

		presentationController.gutterView = NSHostingView(rootView: Color.yellow.ignoresSafeArea())
//		presentationController.underlayView = NSHostingView(rootView: Color.red)
//		presentationController.overlayView = NSHostingView(rootView: Color.blue)
		presentationController.documentView = NSHostingView(rootView: phonyDocView.ignoresSafeArea())
//		presentationController.documentView = colorView

		// necessary for now to get correct view layout
		presentationController.documentView?.translatesAutoresizingMaskIntoConstraints = false

		let editorItem = NSSplitViewItem(viewController: presentationController)

		let inspectorHost = NSHostingController(rootView: Inspector())
		let inspectorItem = NSSplitViewItem(viewController: inspectorHost)
		inspectorItem.minimumThickness = 140
		inspectorItem.canCollapse = true

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
