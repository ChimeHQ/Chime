import Foundation

import ChimeKit
import Neon
import DocumentContent
import RangeState

extension RangeTarget {
	@MainActor
	public init?(textTarget: TextTarget, metrics: TextMetrics) {
		switch textTarget {
		case .all:
			self = .all
		case let .range(textRange):
			guard let range = NSRange(textRange: textRange, metrics: metrics) else {
				return nil
			}

			self = .range(range)
		case let .set(set):
			self = .set(set)
		}
	}
}

extension TextMetrics.Query {
	init(textRange: ChimeExtensionInterface.TextRange, fill: RangeFillMode) {
		switch textRange {
		case let .range(range):
			self = .location(range.max, fill: fill)
		case let .lineRelativeRange(relativeRange):
			self = .location(relativeRange.upperBound.line, fill: fill)
		}
	}

	/// Build a Query using a TextTarget.
	///
	/// This is tricky, especially if `entireDocument` should be used.
	init(textTarget: ChimeExtensionInterface.TextTarget, fill: RangeFillMode, useEntireDocument: Bool) {
		switch textTarget {
		case .all:
			self = useEntireDocument ? .entireDocument(fill: fill) : .processed
		case let .range(textRange):
			self.init(textRange: textRange, fill: fill)
		case let .set(set):
			self = .location(set.max() ?? 0, fill: fill)
		}
	}
}

