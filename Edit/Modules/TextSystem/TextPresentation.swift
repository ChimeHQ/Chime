import Foundation

import NSUI
import Rearrange

public struct TextPresentation {
	public let applyRenderingStyle: ([NSAttributedString.Key : Any], NSRange) -> Void
}

extension TextPresentation {
	@MainActor
	public init(textView: NSUITextView) {
		if let textLayoutManager = textView.textLayoutManager {
			self.init(textLayoutManager: textLayoutManager, textView: textView)
		} else {
			self.init(layoutManager: textView.nsuiLayoutManager!)
		}
	}
	
	@MainActor
	public init(textLayoutManager: NSTextLayoutManager, textView: NSUITextView) {
		self.init(
			applyRenderingStyle: { attrs, range in
				guard
					let contentManager = textLayoutManager.textContentManager,
					let textRange = NSTextRange(range, provider: contentManager)
				else {
					return
				}

				let selection = textView.selectedRanges

				textLayoutManager.setRenderingAttributes(attrs, for: textRange)

				textView.selectedRanges = [NSValue(range: range)]

				textView.selectedRanges = selection
			}
		)
	}

	@MainActor
	public init(layoutManager: NSLayoutManager) {
		self.init(
			applyRenderingStyle: { attrs, range in
#if os(macOS)
				layoutManager.setTemporaryAttributes(attrs, forCharacterRange: range)
#else
				print("unsupported rendering style")
#endif
			}
		)
	}
}
