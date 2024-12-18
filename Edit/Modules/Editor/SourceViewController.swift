import SwiftUI

import SourceView
import TextFormation
import Theme
import ThemePark

public final class SourceViewController: NSViewController {

	public let sourceView: SourceView
	public var selectionChangedHandler: () -> Void = {}
	public var shouldChangeTextHandler: (NSRange, String?) -> Bool = { _, _ in true }

	public init() {
		let textContainer = NSTextContainer(size: CGSize(width: 0.0, height: 1.0e7))
		textContainer.widthTracksTextView = true
		textContainer.heightTracksTextView = false
		let textContentManager = NSTextContentStorage()
		let textLayoutManager = NSTextLayoutManager()
		textLayoutManager.textContainer = textContainer
		textContentManager.addTextLayoutManager(textLayoutManager)

		self.sourceView = SourceView(frame: .zero, textContainer: textContainer)

		super.init(nibName: nil, bundle: nil)

		sourceView.delegate = self
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func loadView() {
		sourceView.drawsBackground = false
		
		let observingView = Text("")
			.hidden()
			.onThemeChange { [weak self] in self?.updateTheme($0, context: $1) }

		let hiddenView = NSHostingView(rootView: observingView)

		sourceView.addSubview(hiddenView)

		self.view = sourceView
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
		selectionChangedHandler()
	}
}
