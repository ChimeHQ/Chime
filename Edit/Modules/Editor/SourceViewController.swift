import AppKit
import SwiftUI

import ChimeKit
import DocumentContent
import SourceView
import TextStory
import Theme

public final class SourceViewController: NSViewController {
	public let sourceView = SourceView()
	public var selectionChangedHandler: ([NSRange]) -> Void = { _ in }
	public var shouldChangeTextHandler: (NSRange, String?) -> Bool = { _, _ in true }

	public init() {
		super.init(nibName: nil, bundle: nil)

		sourceView.drawsBackground = false
		sourceView.wrapsTextToHorizontalBounds = false

		sourceView.delegate = self
		self.representedObject = TSYTextStorage()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func loadView() {
		let observingView = Text("")
			.hidden()
			.onThemeChange { [weak self] in self?.updateTheme($0, context: $1) }

		let hiddenView = NSHostingView(rootView: observingView)

		sourceView.addSubview(hiddenView)

		self.view = sourceView
	}

	public var storage: TextStorage {
		.init(textView: self.sourceView)
	}

	private var representedStorage: TSYTextStorage {
		representedObject as! TSYTextStorage
	}

	override public var representedObject: Any? {
		didSet {
			if sourceView.textContentStorage?.textStorage === representedStorage {
				return
			}
			
			sourceView.textContentStorage?.textStorage = representedStorage

			representedStorage.storageDelegate = self
		}
	}

	public func reload(from url: URL, documentConfiguration: ChimeKit.DocumentConfiguration, theme: Theme) throws {
		let context = Theme.Context(window: view.window)

		let attrs = theme.typingAttributes(tabWidth: documentConfiguration.tabWidth, context: context)

		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.defaultAttributes: attrs,
		]

		self.representedObject = try TSYTextStorage(url: url, options: options, documentAttributes: nil)
	}
}

extension SourceViewController {
	public func updateTheme(_ theme: Theme, context: Theme.Context) {
		sourceView.typingAttributes = [
			.font: theme.font(for: .source, context: context),
			.foregroundColor: theme.color(for: .source, context: context),
		]

		sourceView.insertionPointColor = theme.color(for: .insertionPoint, context: context)
	}
}

extension SourceViewController: NSTextViewDelegate {
	public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
		shouldChangeTextHandler(affectedCharRange, replacementString)
	}

	public func textViewDidChangeSelection(_ notification: Notification) {
		let ranges = sourceView.selectedTextRanges

		selectionChangedHandler(ranges)
	}
}

extension SourceViewController: TSYTextStorageDelegate {
	public nonisolated func textStorage(_ textStorage: TSYTextStorage, doubleClickRangeForLocation location: UInt) -> NSRange {
		textStorage.internalStorage.doubleClick(at: Int(location))
	}

	public nonisolated func textStorage(_ textStorage: TSYTextStorage, nextWordIndexFromLocation location: UInt, direction forward: Bool) -> UInt {
		UInt(textStorage.internalStorage.nextWord(from: Int(location), forward: forward))
	}
}
