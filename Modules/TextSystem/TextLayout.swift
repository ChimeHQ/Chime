import Foundation

import Glyph
import NSUI
import Rearrange

public struct TextLayout {
	public struct LineFragment {
		public let range: NSRange
		public let bounds: CGRect
	}

	public let visibleRect: () -> CGRect
	public let visibleSet: () -> IndexSet
	public let lineFragmentsInRect: (CGRect) -> [LineFragment]
	public let lineFragmentsInRange: (NSRange) -> [LineFragment]
}

extension TextLayout.LineFragment : CustomStringConvertible {
	public var description: String {
		"<LineFragment: \(range), \(bounds)>"
	}
}

extension TextLayout {
	@MainActor
	public init(textView: NSUITextView) {
		self.init(container: textView.nsuiTextContainer!, textView: textView)
	}

	@MainActor
	public init(container: NSTextContainer, textView: NSUITextView) {
		self.init(
			visibleRect: {
				textView.visibleRect
			},
			visibleSet: {
				textView.visibleCharacterIndexes
			},
			lineFragmentsInRect: { rect in
				var fragments = [LineFragment]()

				container.enumerateLineFragments(for: rect, strictIntersection: true) { fragmentRect, fragmentRange, _ in
					fragments.append(.init(range: fragmentRange, bounds: fragmentRect))
				}

				return fragments
			},
			lineFragmentsInRange: { range in
				var fragments = [LineFragment]()

				container.enumerateLineFragments(in: range) { fragmentRect, fragmentRange, _ in
					fragments.append(.init(range: fragmentRange, bounds: fragmentRect))
				}

				return fragments
			}
		)
	}
}
