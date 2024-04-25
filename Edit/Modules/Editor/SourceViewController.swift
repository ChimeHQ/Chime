import AppKit
import SwiftUI

import SourceView
//import TextViewPlus
import Theme
import ThemePark

public final class SourceViewController: NSViewController {
//	private let sourceView = SourceView()
	private let sourceView = NSTextView(usingTextLayoutManager: false)
	public var selectionChangedHandler: ([NSRange]) -> Void = { _ in }
	public var shouldChangeTextHandler: (NSRange, String?) -> Bool = { _, _ in true }
	public var willLayoutHandler: () -> Void = { }
	public var didLayoutHandler: () -> Void = { }

	private var set = Set<NSKeyValueObservation>()

	public init() {
		super.init(nibName: nil, bundle: nil)

		sourceView.drawsBackground = false
		sourceView.wrapsTextToHorizontalBounds = true
		sourceView.textContainer?.size.width = sourceView.frame.width
		sourceView.isHorizontallyResizable = false

		// temp stuff
		let max = CGFloat.greatestFiniteMagnitude

		sourceView.minSize = NSSize.zero
		sourceView.maxSize = NSSize(width: max, height: max)
		sourceView.isVerticallyResizable = true
		sourceView.isHorizontallyResizable = true
		sourceView.autoresizingMask = [.width, .height]

		// make sure to do this on
		if sourceView.textLayoutManager == nil {
			sourceView.layoutManager?.allowsNonContiguousLayout = true
		}

		// end temp stuff

		sourceView.delegate = self
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

	public var textView: NSTextView {
		sourceView
	}
}

extension SourceViewController {
	public func updateTheme(_ theme: Theme, context: Query.Context) {
		let syntaxStyle = theme.style(for: .init(key: .syntax(.text), context: context))

		sourceView.typingAttributes = [
			.font: syntaxStyle.font ?? Theme.fallbackFont,
			.foregroundColor: syntaxStyle.color,
		]

		let cursorColor = theme.color(for: .init(key: .editor(.cursor), context: context))

		sourceView.insertionPointColor = cursorColor
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
