import AppKit
import SwiftUI

fileprivate extension NSUserInterfaceItemIdentifier {
	static let navigatorViewController = NSUserInterfaceItemIdentifier("com.chimehq.Navigator")
	static let navigatorContentColumn = NSUserInterfaceItemIdentifier("com.chimehq.Navigator.Content")
	static let navigatorStatusColumn = NSUserInterfaceItemIdentifier("com.chimehq.Navigator.Status")
}

final class NavigatorViewController<Value: Hashable>: NSViewController, NSOutlineViewDataSource {
	typealias Model = NavigatorModel<Value>

	private let outlineView = NSOutlineView()
	private let scrollView = NSScrollView()
	let model: Model

	init(model: Model) {
		self.model = model

		super.init(nibName: nil, bundle: nil)

//		outlineView.delegate = self
		outlineView.dataSource = self

		self.identifier = .navigatorViewController

		outlineView.autosaveName = Self.autosaveName(with: model.root.value)
		outlineView.autosaveExpandedItems = outlineView.autosaveName != nil
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static func autosaveName(with value: Value) -> String? {
		guard UserDefaults.standard.bool(forKey: "ApplePersistenceIgnoreState") == false else {
			return nil
		}

		let id = NSUserInterfaceItemIdentifier.navigatorViewController

		return "\(id)-\(value.hashValue)"
	}

	override func loadView() {
		let contentColumn = NSTableColumn(identifier: .navigatorContentColumn)
		contentColumn.isEditable = false

		outlineView.addTableColumn(contentColumn)

		let statusColumn = NSTableColumn(identifier: .navigatorStatusColumn)
		statusColumn.isEditable = false

		// setting this to a small value appears to make the view try to keep the column as small as possible
		statusColumn.width = 2.0

		outlineView.addTableColumn(statusColumn)

		outlineView.headerView = nil
		outlineView.allowsTypeSelect = true
		outlineView.allowsMultipleSelection = true
		outlineView.allowsColumnSelection = false
		outlineView.allowsColumnReordering = false
		outlineView.usesAutomaticRowHeights = true
		outlineView.columnAutoresizingStyle = .reverseSequentialColumnAutoresizingStyle

		outlineView.target = self
//		outlineView.action = #selector(outlineViewClicked(_:))
//		outlineView.doubleAction = #selector(outlineViewDoubleClicked(_:))

		outlineView.setDraggingSourceOperationMask([.move, .copy, .delete], forLocal: false)
		outlineView.setDraggingSourceOperationMask([.move, .copy], forLocal: true)
		outlineView.registerForDraggedTypes([.fileURL])

		// these two settings are necessary for NSTableCellView to display correctly
		outlineView.selectionHighlightStyle = .regular
		outlineView.rowSizeStyle = .default

		// the docs say that setting outlineView.rowHeight (or implementing a delegate call)
		// can improve scroll bar behavior. i have not actually seen issues, except
		// with reload/expand, and this doesn't seem to make a difference in that case.

		scrollView.documentView = outlineView
		scrollView.drawsBackground = false
		scrollView.hasVerticalScroller = true
		scrollView.automaticallyAdjustsContentInsets = false

		self.view = scrollView

		outlineView.reloadData()
	}

	// MARK: NSOutlineViewDataSource
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		let node = (item as? Model.Node) ?? model.root

		return model.children(for: node).count
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		let node = (item as? Model.Node) ?? model.root

		return model.children(for: node)[index]
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		let node = item as! Model.Node

		return model.nodeHasChildren(node)
	}

	func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
		// have to fill this back in
		nil
	}

	func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
		(item as? Model.Node)?.value
	}

	// MARK: NSOutlineViewDelegate
}

struct NavigatorView<Value: Hashable>: NSViewControllerRepresentable {
	public let model: NavigatorModel<Value>

	public init(model: NavigatorModel<Value>) {
		self.model = model
	}

	public func makeNSViewController(context: Context) -> NavigatorViewController<Value> {
		NavigatorViewController(model: model)
	}

	public func updateNSViewController(_ nsViewController: NavigatorViewController<Value>, context: Context) {
	}
}
