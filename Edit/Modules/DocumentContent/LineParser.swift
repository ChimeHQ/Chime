import Foundation

public struct LineParser {
	private let nonWhitespaceCharacterSet = CharacterSet.whitespacesAndNewlines.inverted

	public init() {
	}

	private func lineRanges(in string: String) -> [Range<String.Index>] {
		var ranges: [Range<String.Index>] = []
		var idx = string.startIndex

		while idx < string.endIndex {
			let lineRange = string.lineRange(for: idx..<idx)

			ranges.append(lineRange)

			idx = lineRange.upperBound
		}

		// make sure there's at least one range, which covers the entire string
		if ranges.isEmpty {
			let range = string.startIndex..<string.endIndex
			return [range]
		}

		return ranges
	}

	public func parseLines(in string: String, indexOffset: Int, locationOffset: Int, includeLastLine: Bool) -> [Line] {
		let charRanges = lineRanges(in: string)

		var lines: [Line] = []

		for (i, charRange) in charRanges.enumerated() {
			let range = NSRange(charRange, in: string)
			let offsetRange = NSRange(location: range.location + locationOffset, length: range.length)
			let whitespaceOnly = string.rangeOfCharacter(from: nonWhitespaceCharacterSet, options: [], range: charRange) == nil

			let line = Line(index: indexOffset + i, range: offsetRange, whitespaceOnly: whitespaceOnly)

			lines.append(line)
		}

		if !includeLastLine {
			return lines
		}

		if let lastIndex = string.index(string.endIndex, offsetBy: -1, limitedBy: string.startIndex) {
			if string[lastIndex] == "\n" {
				let range = NSRange(string.endIndex..<string.endIndex, in: string)
				let offsetRange = NSRange(location: range.location + locationOffset, length: range.length)
				let line = Line(index: indexOffset + charRanges.count, range: offsetRange, whitespaceOnly: true)

				lines.append(line)
			}
		}

		return lines
	}
}
