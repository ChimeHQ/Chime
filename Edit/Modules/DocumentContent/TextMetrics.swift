import Foundation

import Borderline
import Rearrange
import RelativeCollections
import RangeState

//extension RelativeList {
//	func replaceSubrange<Elements>(_ range: Range<Index>, with newElements: Elements) where WeightedValue == Elements.Element, Elements : Sequence {
//		// this is a naive implemenation and it is very suboptimal
//		for i in range.reversed() {
//			remove(at: i)
//		}
//
//		for element in newElements.reversed() {
//			insert(element, at: range.lowerBound)
//		}
//	}
//}
//
//extension Line where TextPosition == Int {
//	init(record: TextMetrics.List.Record, index: Int) {
//		self.init(
//			index: index,
//			start: record.dependency,
//			lengths: record.value
//		)
//	}
//
//	var weightedValue: TextMetrics.List.WeightedValue {
//		.init(
//			value: lengths,
//			weight: lengths.total
//		)
//	}
//}

public struct TextMetrics : Sendable {
	typealias List = RelativeArray<LineComponentLengths, Int>
//	typealias List = RelativeList<LineValue, Int>
	var lineList = List()
	var storageVersion: Int = 0
	var storageLength: Int = 0

	public init() {
		// insert a single empty line as a starting point
		let line = Line<Int>(
			index: 0,
			start: 0,
			lengths: .empty
		)

		lineList.append(line.weightedValue)
//		lineList.insert(line.weightedValue, at: 0)
	}

	public func lines(for range: NSRange) -> [Line<Int>] {
		let lowerIndex = lastLineIndex(before: range.location) ?? lineList.startIndex
		let upperIndex = firstLineIndex(after: range.max) ?? lineList.endIndex

		// that upper is *past* the range we are interested in

		return lineList[lowerIndex..<upperIndex].enumerated().map { index, record in
			Line(record: record, index: index + lowerIndex)
		}
	}

	public func line(for location: Int) -> Line<Int>? {
		guard let idx = lastLineIndex(before: location) else { return nil }

		return Line(record: lineList[idx], index: idx)
	}

	public func line(at index: Int) -> Line<Int>? {
		lineList[safe: index].map { Line(record: $0, index: index) }
	}

	public var lastLine: Line<Int> {
		let idx = lineList.endIndex - 1

		precondition(idx >= 0)

		return line(at: idx)!
	}

	public var lineCount: Int {
		lineList.count
	}
}

extension TextMetrics {
	public func firstLineIndex(after location: Int) -> Int? {
		lineList.binarySearch { record, _ in
			location < record.dependency
		}
	}

	public func lastLineIndex(before location: Int) -> Int? {
		let descIdx = lineList.reversed().firstIndex { record in
			record.dependency <= location
		}

		guard let descIdx else { return nil }

		// have to adjust the index around here because we used reversed()
		return lineList.index(before: descIdx.base)
	}
}

extension TextMetrics {
	public func lineSpan(for range: NSRange) -> (Line<Int>, Line<Int>)? {
		let max = range.upperBound
		let min = range.lowerBound

		guard let start = line(for: min) else {
			return nil
		}

		// just skip a lookup if we can
		if start.range(of: .full).contains(max) {
			return (start, start)
		}

		guard let end = line(for: max) else {
			return nil
		}

		return (start, end)
	}
}
