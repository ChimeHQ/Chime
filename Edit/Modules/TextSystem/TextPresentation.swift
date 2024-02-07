import AppKit
import Foundation

import Rearrange

public struct TextPresentation {
	public let applyRenderingStyle: ([NSAttributedString.Key : Any], NSRange) -> Void
}

extension TextPresentation {
	@MainActor
	public init(textView: NSTextView) {
		if let textLayoutManager = textView.textLayoutManager {
			self.init(textLayoutManager: textLayoutManager)
		} else {
			self.init(layoutManager: textView.layoutManager!)
		}
	}
	
	@MainActor
	public init(textLayoutManager: NSTextLayoutManager) {
		self.init(
			applyRenderingStyle: { attrs, range in
				guard
					let contentManager = textLayoutManager.textContentManager,
					let textRange = NSTextRange(range, provider: contentManager)
				else {
					return
				}

				let textView = textLayoutManager.textContainer?.textView

				let selection = textView?.selectedRanges

				textLayoutManager.setRenderingAttributes(attrs, for: textRange)

				textView?.selectedRanges = [NSValue(range: range)]

				if let selection {
					textView?.selectedRanges = selection
				}
			}
		)
	}

	@MainActor
	public init(layoutManager: NSLayoutManager) {
		self.init(
			applyRenderingStyle: { attrs, range in
				layoutManager.setTemporaryAttributes(attrs, forCharacterRange: range)
			}
		)
	}
}
