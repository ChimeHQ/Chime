import AppKit
import SwiftUI

import Inspector
import Navigator
import Search
import Theme
import UIUtility

/// Defines the overall editor scene.
///
/// This controller establishes the larger editor scene, typing together the sub components.
public final class EditorContentViewController: NSViewController {
	let controller = NSSplitViewController()
	let editorScrollView = NSScrollView()
	let sourceViewController = SourceViewController()

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

		// allow the scroll view to use the entire height of a full-content windows
		editorScrollView.automaticallyAdjustsContentInsets = false

		// set up the trailing and leading sidebars
		let navigatorHost = NSHostingController(rootView: Navigator())
		let navigatorItem = NSSplitViewItem(sidebarWithViewController: navigatorHost)

		let inspectorHost = NSHostingController(rootView: Inspector())
		let inspectorItem = NSSplitViewItem(viewController: inspectorHost)
		inspectorItem.minimumThickness = 140
		inspectorItem.canCollapse = true

		// set up the main source presentation
		let presentationController = SourcePresentationViewController(scrollView: editorScrollView)

		presentationController.gutterView = NSHostingView(rootView: Color.yellow.ignoresSafeArea())
//		presentationController.underlayView = NSHostingView(rootView: Color.red)
//		presentationController.overlayView = NSHostingView(rootView: Color.blue)
		presentationController.documentView = sourceViewController.view

		// For debugging. Just be careful, because the SourceView/ScrollView relationship is extremely complex.
//		presentationController.documentView = NSHostingView(rootView: BoundingBorders())
//		presentationController.documentView?.translatesAutoresizingMaskIntoConstraints = false

		let presentationHost = RepresentableViewController.wrap(controller: presentationController) { presentationView in
			EditorContent {
				presentationView
			} themeUpdateAction: { [sourceViewController] in
				sourceViewController.updateTheme($0, context: $1)
			}

		}

		let editorItem = NSSplitViewItem(viewController: presentationHost)
		editorItem.minimumThickness = 200

		controller.splitViewItems = [navigatorItem, editorItem, inspectorItem]

		self.view = controller.view
	}
}
