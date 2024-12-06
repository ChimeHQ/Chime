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
				textView.setRenderingAttributes(attrs, for: range)
			}
		)
	}
}
