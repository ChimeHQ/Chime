import Cocoa
import Combine
import SwiftUI

import ChimeKit
import ScrollViewPlus
import UIUtility
import ViewPlus
import WindowTreatment

extension NSUserInterfaceItemIdentifier {
    static let openQuicklyItemColumn = NSUserInterfaceItemIdentifier(rawValue: "column")
}

final class KeyboardlessTableView: NSTableView {
    override var acceptsFirstResponder: Bool {
        return false
    }
}

final class OpenQuicklyViewController: XiblessViewController<NSView> {
    let inputView: NSTextField
    let tableView: NSTableView
    let viewModel: OpenQuicklyViewModel

    private var heightConstraint: NSLayoutConstraint?
    private var subscriptions = Set<AnyCancellable>()
    private var items: [OpenQuicklyItem] = []
    private var querySubject = PassthroughSubject<String, Never>()

    init(context: OpenQuicklyContext, symbolQueryService: SymbolQueryService?) {
        self.inputView = NSTextField()
        self.tableView = KeyboardlessTableView()
        self.viewModel = OpenQuicklyViewModel(context: context, symbolQueryService: symbolQueryService)

        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        viewModel.$items.sink { newItems in
            self.items = newItems
            self.tableView.reloadData()
            self.updateWindowSize()
        }.store(in: &subscriptions)

        viewModel.$searchState.sink { state in
            switch state {
            case .inactive:
                self.inputView.textColor = .disabledControlTextColor
            case .active, .complete:
                self.inputView.textColor = .textColor
            }
        }.store(in: &subscriptions)

        querySubject
            .throttle(for: .milliseconds(250), scheduler: RunLoop.main, latest: true)
            .sink { query in
                self.viewModel.performSearch(with: query)
            }.store(in: &subscriptions)
    }

    override func loadView() {
		self.view = NSView() // NSHostingView(rootView: RoundedRectangle(cornerRadius: 15.0))

        inputView.placeholderString = "Open Quickly"
        inputView.font = NSFont.systemFont(ofSize: 18.0)
        inputView.drawsBackground = false
        inputView.isBezeled = false
        inputView.focusRingType = .none
        inputView.isEditable = true
        inputView.lineBreakMode = .byTruncatingHead
        inputView.delegate = self

        let searchImage = NSImageView(systemSymbolName: "magnifyingglass")
        searchImage.imageScaling = .scaleProportionallyUpOrDown

        let column = NSTableColumn(identifier: .openQuicklyItemColumn)

        tableView.addTableColumn(column)
        tableView.columnAutoresizingStyle = .reverseSequentialColumnAutoresizingStyle
        tableView.headerView = nil
        tableView.backgroundColor = .clear
        tableView.usesAutomaticRowHeights = true
        tableView.allowsEmptySelection = false
        tableView.allowsColumnResizing = false
        tableView.allowsColumnSelection = false
        tableView.allowsMultipleSelection = false
        tableView.action = #selector(acceptSelection(_:))
        tableView.target = self
        tableView.doubleAction = #selector(acceptSelection(_:))
        tableView.target = self
        tableView.setAccessibilityTitle("Open Quickly Results")

        let scrollView = OverlayOnlyScrollView()

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false

        scrollView.documentView = tableView

        view.subviews = [searchImage, inputView, scrollView]
        view.subviewsUseAutoLayout = true

        let scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: 0.0)

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 450),

            searchImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            searchImage.widthAnchor.constraint(equalToConstant: 20.0),
            searchImage.centerYAnchor.constraint(equalTo: inputView.centerYAnchor),
            searchImage.heightAnchor.constraint(equalTo: searchImage.widthAnchor),

            inputView.leadingAnchor.constraint(equalTo: searchImage.trailingAnchor, constant: 10.0),
            inputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            inputView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10.0),

            scrollView.topAnchor.constraint(equalTo: inputView.bottomAnchor, constant: 10.0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewHeightConstraint,
        ])

        self.heightConstraint = scrollViewHeightConstraint
    }

    override func cancelOperation(_ sender: Any?) {
        view.window?.close()
    }

    private func updateWindowSize() {
        // This is really crummy, but I cannot figure out a great
        // way to calculate the actual hight requirement.
        let count = CGFloat(self.numberOfRows(in: tableView))

        let height: CGFloat

        if count == 0 {
            height = 0.0

            tableView.deselectAll(self)
        } else {
            let displayCount = min(8.5, count)

            let rowHeight = 46.0

            height = 10.0 + 20.0 + displayCount * rowHeight
        }

        // NSWindow sizing animation is tricky. Using the
        // animator() property does the right thing, but
        // implicit animations do not.
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1

            self.heightConstraint?.animator().constant = height
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        updateWindowSize()
    }

    var symbolQueryService: SymbolQueryService? {
        get { viewModel.symbolQueryService }
        set {
            viewModel.symbolQueryService = newValue

            // when services change, re-send the query
            if self.view.windowIsKey {
                querySubject.send(inputView.stringValue)
            }
        }
    }

    @objc
    private func acceptSelection(_ sender: Any) {
        let index = tableView.selectedRow

        guard index > -1 && index < items.count else {
            return
        }


        viewModel.activateSelection(with: index)
    }

    private func computeSelectedIndex(up: Bool) -> Int? {
        let count = items.count
        let limit = count - 1

        if count == 0 {
            return nil
        }

        let row = tableView.selectedRow == -1 ? nil : tableView.selectedRow

        switch (up, row) {
        case (true, nil):
            return 0
        case (true, let row?):
            return max(row - 1, 0)
        case (false, nil):
            return limit
        case (false, let row?):
            return min(row + 1, limit)
        }
    }

    private func adjustSelection(up: Bool) {
        guard let row = computeSelectedIndex(up: up) else {
            tableView.deselectAll(self)
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
}

extension OpenQuicklyViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        querySubject.send(inputView.stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(moveUp(_:)):
            adjustSelection(up: true)

            return true
        case #selector(moveDown(_:)):
            adjustSelection(up: false)

            return true
        case #selector(insertNewline(_:)):
            acceptSelection(self)

            return true
        default:
            return false
        }
    }
}

extension OpenQuicklyViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return IgnoringFocusRowView()
    }
}

extension OpenQuicklyViewController: NSTableViewDataSource {
    private func item(at index: Int) -> OpenQuicklyItem {
        return items[index]
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = item(at: row)

        let cellView = tableView.makeReusableView(for: .openQuicklyItemColumn) {
            return NSHostingView(rootView: ItemView(item: item))
        }

        cellView.rootView = ItemView(item: item)

        return cellView
    }
}
