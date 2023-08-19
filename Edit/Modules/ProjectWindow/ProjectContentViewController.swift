import AppKit
import SwiftUI

import Inspector
import Navigator

final class PlainOutlineViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
	private let outlineView = NSOutlineView()

	init() {
		super.init(nibName: nil, bundle: nil)

		outlineView.delegate = self
		outlineView.dataSource = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func loadView() {
		let contentColumn = NSTableColumn(identifier: .init("mycolumn"))
		contentColumn.isEditable = false

		outlineView.addTableColumn(contentColumn)

		outlineView.headerView = nil
		outlineView.allowsTypeSelect = true
		outlineView.allowsMultipleSelection = true
		outlineView.allowsColumnSelection = false
		outlineView.allowsColumnReordering = false
		outlineView.usesAutomaticRowHeights = true
		outlineView.columnAutoresizingStyle = .reverseSequentialColumnAutoresizingStyle

//		outlineView.target = self
//		outlineView.action = #selector(outlineViewClicked(_:))
//		outlineView.doubleAction = #selector(outlineViewDoubleClicked(_:))

//		outlineView.setDraggingSourceOperationMask([.move, .copy, .delete], forLocal: false)
//		outlineView.setDraggingSourceOperationMask([.move, .copy], forLocal: true)
//		outlineView.registerForDraggedTypes([.fileURL])

		// these two settings are necessary for NSTableCellView to display correctly
		outlineView.style = .automatic
		outlineView.rowSizeStyle = .default

		self.view = outlineView
	}

	// MARK: NSOutlineViewDataSource
	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		switch item as? String {
		case nil:
			return 3
		case "a", "b", "c":
			return 4
		default:
			return 0
		}
	}

	public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		switch item as? String {
		case nil:
			return ["a", "b", "c"][index]
		case "a", "b", "c":
			return ["1", "2", "3", "4"][index]
		default:
			fatalError()
		}
	}

	public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item as? String {
		case nil, "a", "b", "c":
			return true
		default:
			return false
		}
	}

	// MARK: NSOutlineViewDelegate
	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		let view = NSTextField(labelWithString: item as? String ?? "hmm")

		return view
	}

}

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
//		let navigatorItem = NSSplitViewItem(sidebarWithViewController: PlainOutlineViewController())

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
