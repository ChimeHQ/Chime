import SwiftUI

import SourceView
import Theme
import ThemePark
import IBeam

public final class SourceViewController: NSViewController {

	public let sourceView: MultiCursorTextView
	public var selectionChangedHandler: () -> Void = {}

	public init() {
		let textContainer = NSTextContainer.defaultTextKit2Container

		self.sourceView = MultiCursorTextView(frame: .zero, textContainer: textContainer)

		super.init(nibName: nil, bundle: nil)

		sourceView.configureForHorizontalScrolling()
		sourceView.isRichText = false
		sourceView.wrapsTextToHorizontalBounds = true

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
		let syntaxStyle = theme.style(for: .init(key: .syntax(.text(nil)), context: context))

		sourceView.typingAttributes = [
			.font: syntaxStyle.font ?? Theme.fallbackFont,
			.foregroundColor: syntaxStyle.color,
		]
	}
}

extension SourceViewController: NSTextViewDelegate {
	public func textViewDidChangeSelection(_ notification: Notification) {
		selectionChangedHandler()
	}
}
