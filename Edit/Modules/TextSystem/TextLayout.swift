import Foundation

import Glyph
import NSUI
import Rearrange

public struct TextLayout {
	public struct LineFragment {
		public let range: NSRange
		public let bounds: NSRect
	}

	public let visibleRect: () -> NSRect
	public let visibleSet: () -> IndexSet
	public let lineFragmentsInRect: (NSRect) -> [LineFragment]
	public let lineFragmentsInRange: (NSRange) -> [LineFragment]
}

extension TextLayout {
	@MainActor
	public init(textView: NSUITextView) {
		self.init(container: textView.textContainer!)
	}

	@MainActor
	public init(container: NSTextContainer) {
		self.init(
			visibleRect: {
				container.textView!.visibleRect
			},
			visibleSet: {
				container.textView!.visibleCharacterIndexes
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
