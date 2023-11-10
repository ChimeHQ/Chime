import AppKit

import SourceView
import Theme

public final class SourceViewController: NSViewController {
	let sourceView = SourceView()

	public init(storage: NSTextStorage) {
		super.init(nibName: nil, bundle: nil)

		sourceView.drawsBackground = false
		sourceView.wrapsTextToHorizontalBounds = false

		sourceView.delegate = self

		self.representedObject = storage
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func loadView() {
		self.view = sourceView
	}

	var representedContent: NSTextStorage {
		representedObject as! NSTextStorage
	}

	override public var representedObject: Any? {
		didSet {
			if sourceView.textContentStorage?.textStorage === representedContent {
				return
			}
			
			sourceView.textContentStorage?.textStorage = representedContent
		}
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
	public func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		return true
	}
}
