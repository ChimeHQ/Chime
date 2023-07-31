import AppKit

import SourceView

public final class SourceViewController: NSViewController {
	let sourceView = SourceView()

	public init() {
		super.init(nibName: nil, bundle: nil)

		sourceView.delegate = self
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func loadView() {
		self.view = sourceView
	}
}

extension SourceViewController: NSTextViewDelegate {
	public func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		return true
	}
}
