import Foundation

import Glyph
import NSUI

public struct TextPresentation {
	public let applyRenderingStyle: ([NSAttributedString.Key : Any], NSRange) -> Void
}

extension TextPresentation {
	@MainActor
	public init(textView: NSUITextView) {
		self.init(
			applyRenderingStyle: { attrs, range in
				// rendering attributes are less powerful but much less expensive
//				textView.setRenderingAttributes(attrs, for: range)

				guard let storage = textView.nsuiTextStorage else {
					fatalError("A few without storage is unsupported")
				}

//				let selection = textView.selectedRange()

				let effectiveAttrs = attrs.merging(textView.typingAttributes) { lhs, rhs in
					lhs
				}

				storage.setAttributes(effectiveAttrs, range: range)
//
//				textView.setSelectedRange(range)
//				textView.setSelectedRange(selection)
			}
		)
	}
}
