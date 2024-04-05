import AppKit
import Foundation

import Glyph
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

extension NSTextLayoutManager {
	func textLayoutFragment(atOrBefore point: CGPoint) -> NSTextLayoutFragment? {
		if let fragment = textLayoutFragment(for: point) {
			return fragment
		}

		return nil
	}

	func enumerateTextLayoutFragments(in rect: CGRect, options: NSTextLayoutFragment.EnumerationOptions = [], using block: (NSTextLayoutFragment) -> Bool) {
		// if this is nil, our optmizations will have no effect
		let viewportRange = textViewportLayoutController.viewportRange ?? documentRange
		let viewportBounds = textViewportLayoutController.viewportBounds
		let reversed = options.contains(.reverse)

		// we're going to start at a document limit, which is definitely correct but suboptimal

		var location: NSTextLocation

		if reversed {
			location = documentRange.endLocation

			if rect.maxY <= viewportBounds.maxY {
				location = viewportRange.endLocation
			}

			if rect.maxY <= viewportBounds.minY {
				location = viewportRange.location
			}
		} else {
			location = documentRange.location

			if rect.minY >= viewportBounds.minY {
				location = viewportRange.location
			}

			if rect.minY >= viewportBounds.maxY {
				location = viewportRange.endLocation
			}
		}

		enumerateTextLayoutFragments(from: location, options: options, using: { fragment in
			let keepGoing: Bool

			if reversed {
				keepGoing = fragment.layoutFragmentFrame.minY < rect.minY
			} else {
				keepGoing = fragment.layoutFragmentFrame.maxY < rect.maxY
			}

			if keepGoing == false {
				return false
			}

			return block(fragment)
		})
	}
}

extension NSTextLayoutFragment {
	func lineFragments(for provider: NSTextElementProvider) -> [TextLayout.LineFragment] {
		let origin = layoutFragmentFrame.origin
		let location = provider.offset?(from: provider.documentRange.location, to: rangeInElement.location) ?? 0

		// check to ensure our shift will always be valid
		precondition(location >= 0)
		precondition(location != NSNotFound)

		return textLineFragments.map { textLineFragment in
			let bounds = textLineFragment.typographicBounds.offsetBy(dx: origin.x, dy: origin.y)
			let range = textLineFragment.characterRange.shifted(by: location)!

			return TextLayout.LineFragment(range: range, bounds: bounds)
		}
	}
}

extension TextLayout {
	@MainActor
	public init(textView: NSTextView) {
//		if let textLayoutManager = textView.textLayoutManager {
//			self.init(textLayoutManager: textLayoutManager)
//		} else {
//			self.init(layoutManager: textView.layoutManager!, container: textView.textContainer!)
//		}
		self.init(container: textView.textContainer!)
	}

	@MainActor
	public init(textLayoutManager: NSTextLayoutManager) {
		self.init(
			visibleRect: {
				textLayoutManager.textViewportLayoutController.viewportBounds
			},
			visibleSet: {
				guard
					let contentManager = textLayoutManager.textContentManager,
					let textRange = textLayoutManager.textViewportLayoutController.viewportRange
				else {
					return IndexSet()
				}

				return IndexSet(NSRange(textRange, provider: contentManager))
			},
			lineFragmentsInRect: { rect in
				guard let contentManager = textLayoutManager.textContentManager else { return [] }

				let options: NSTextLayoutFragment.EnumerationOptions = [.ensuresLayout, .ensuresExtraLineFragment]

				var fragments = [LineFragment]()

				textLayoutManager.enumerateTextLayoutFragments(in: rect, options: options) { fragment in
					let lineFragments = fragment.lineFragments(for: contentManager)

					fragments.append(contentsOf: lineFragments)

					return true
				}

				return fragments
			},
			lineFragmentsInRange: { range in
				guard
					let contentManager = textLayoutManager.textContentManager,
					let contentRange = NSTextRange(range, provider: contentManager)
				else {
					return []
				}

				let options: NSTextLayoutFragment.EnumerationOptions = [.ensuresLayout, .ensuresExtraLineFragment]

				var fragments = [LineFragment]()

				textLayoutManager.enumerateTextLayoutFragments(from: contentRange.location, options: options) { fragment in
					let lineFragments = fragment.lineFragments(for: contentManager)

					fragments.append(contentsOf: lineFragments)

					return fragment.rangeInElement.endLocation < contentRange.endLocation
				}

				return fragments
			}
		)
	}

	@MainActor
	public init(layoutManager: NSLayoutManager, container: NSTextContainer) {
		self.init(
			visibleRect: {
				container.textView!.visibleRect
			},
			visibleSet: {
				container.textSet(for: container.textView!.visibleRect)
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

	@MainActor
	public init(container: NSTextContainer) {
		self.init(
			visibleRect: {
				container.textView!.visibleRect
			},
			visibleSet: {
				container.textSet(for: container.textView!.visibleRect)
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
