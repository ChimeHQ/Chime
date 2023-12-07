import Foundation

public struct Line {
	public let index: Int
	public let range: NSRange
	public let whitespaceOnly: Bool

	public init(index: Int, range: NSRange, whitespaceOnly: Bool = false) {
		self.index = index
		self.range = range
		self.whitespaceOnly = whitespaceOnly
	}

	public var rangeNotIncludingNewline: NSRange {
		let newLength = Swift.max(range.length - 1, 1)

		return NSRange(location: location, length: newLength)
	}
}

public extension Line {
	var location: Int {
		return range.location
	}

	var length: Int {
		return range.length
	}

	var max: Int {
		return NSMaxRange(range)
	}
}

extension Line: Hashable {}
extension Line: Sendable {}

public extension Line {
	func rangeFromBeginning(to endLimit: Int) -> NSRange? {
		if endLimit > max || endLimit < location {
			return nil
		}

		return NSMakeRange(location, endLimit - location)
	}

	func rangeToEnd(from startLimit: Int) -> NSRange? {
		if startLimit > max || startLimit < location {
			return nil
		}

		return NSMakeRange(startLimit, max - startLimit)
	}
}
