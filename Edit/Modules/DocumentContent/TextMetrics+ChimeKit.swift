import Foundation

import ChimeKit

// Initialization
extension LineRelativeTextPosition {
	@MainActor
	public init?(location: Int, metrics: TextMetrics) {
		guard let line = metrics.line(for: location) else {
			return nil
		}

		precondition(line.location <= location)

		let utf16Offset = location - line.location

		self = LineRelativeTextPosition(line: line.index, offset: utf16Offset)
	}
}

extension LineRelativeTextRange {
	@MainActor
	public init?(range: NSRange, metrics: TextMetrics) {
		guard
			let start = LineRelativeTextPosition(location: range.lowerBound, metrics: metrics),
			let end = LineRelativeTextPosition(location: range.upperBound, metrics: metrics)
		else {
			return nil
		}

		self = start..<end
	}
}

extension CombinedTextPosition {
	@MainActor
	public init?(location: Int, metrics: TextMetrics) {
		guard let position = LineRelativeTextPosition(location: location, metrics: metrics) else {
			return nil
		}

		self.init(location: location, relativePosition: position)
	}
}

extension CombinedTextRange {
	@MainActor
	public init?(range: NSRange, metrics: TextMetrics) {
		guard let relativeRange = LineRelativeTextRange(range: range, metrics: metrics) else {
			return nil
		}

		self.init(
			version: metrics.storage.currentVersion,
			range: range,
			lineRelativeRange: relativeRange,
			limit: metrics.storage.currentLength
		)
	}
}

// Translation
extension Line {
	var lineRelativeLowerBound: LineRelativeTextPosition {
		LineRelativeTextPosition(line: index, offset: 0)
	}

	var lineRelativeUpperBound: LineRelativeTextPosition {
		LineRelativeTextPosition(line: index, offset: length)
	}
}

extension LineRelativeTextPosition {
	@MainActor
	public func absoluteLocation(with metrics: TextMetrics, clampOutOfBounds: Bool = false) -> Int? {
		guard let line = metrics.line(at: self.line) else {
			return nil
		}

		if clampOutOfBounds {
			return line.location + min(offset, line.length)
		}

		if offset > line.length {
			assertionFailure()
			return nil
		}

		return line.location + offset
	}
}

extension NSRange {
	@MainActor
	public init?(relativeRange: LineRelativeTextRange, metrics: TextMetrics) {
		guard
			let start = relativeRange.lowerBound.absoluteLocation(with: metrics),
			let end = relativeRange.upperBound.absoluteLocation(with: metrics)
		else {
			return nil
		}

		self.init(start..<end)
	}

	@MainActor
	public init?(textRange: ChimeExtensionInterface.TextRange, metrics: TextMetrics) {
		switch textRange {
		case let .range(range):
			self = range
		case let .lineRelativeRange(relativeRange):
			self.init(relativeRange: relativeRange, metrics: metrics)
		}

	}
}
