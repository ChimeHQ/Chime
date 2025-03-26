import Foundation

import Borderline
import Rearrange
import RelativeCollections
import RangeState

extension RelativeList {
	func replaceSubrange<Elements>(_ range: Range<Index>, with newElements: Elements) where WeightedValue == Elements.Element, Elements : Sequence {
		// this is a naive implemenation and it is very suboptimal
		for i in range.reversed() {
			remove(at: i)
		}

		for element in newElements.reversed() {
			insert(element, at: range.lowerBound)
		}
	}
}

extension Line where TextPosition == Int {
	init(record: TextMetrics.List.Record, index: Int) {
		self.init(
			index: index,
			start: record.dependency,
			lengths: record.value
		)
	}

	var weightedValue: TextMetrics.List.WeightedValue {
		.init(
			value: lengths,
			weight: lengths.total
		)
	}
}

@MainActor
public final class TextMetrics {
	public typealias ValueProvider = HybridSyncAsyncValueProvider<Query, TextMetrics, Never>

	public nonisolated static let invalidationSetKey = "set"
	public nonisolated static let textMetricsDidChangeNotification = Notification.Name("textMetricsDidChangeNotification")

	public typealias Version = Int
	typealias List = RelativeArray<LineComponentLengths, Int>
//	typealias List = RelativeList<LineValue, Int>
	public typealias Storage = TextStorage<Version>
	typealias Processor = RangeProcessor

	public enum Query: Sendable, Hashable {
		case location(Int, fill: RangeFillMode)
		case index(Int, fill: RangeFillMode)
		case entireDocument(fill: RangeFillMode)
		case processed
	}

	private let invalidator = RangeInvalidationBuffer()
	private lazy var rangeProcessor = Processor(
		configuration: .init(
			lengthProvider: { [storage] in storage.currentLength },
			changeHandler: {
				self.didChange($0, completion: $1)
			}
		)
	)

	private let parser = UTF16CodePointLineParser()
	private var lineList = List()
	let storage: Storage
	private var thing: Int = 0

	public init(storage: Storage) {
		self.storage = storage

		// insert a single empty line as a starting point
		let line = Line<Int>(
			index: 0,
			start: 0,
			lengths: .empty
		)

		lineList.append(line.weightedValue)
//		lineList.insert(line.weightedValue, at: 0)
	}

	private func ensureProcessed(_ location: Int) {
		rangeProcessor.processLocation(location, mode: .required)
	}

	public var valueProvider: ValueProvider {
		.init(
			isolation: MainActor.shared,
			rangeProcessor: rangeProcessor,
			inputTransformer: transformQuery,
			syncValue: { _ in self },
			asyncValue: { _ in self }
		)
	}

	private func transformQuery(_ query: Query) -> (Int, RangeFillMode) {
		switch query {
		case let .location(location, fill: fill):
			return (location, fill)
		case let .index(index, fill: fill):
			// we have seen processed this location
			if let location = line(at: index)?.upperBound {
				return (location, fill)
			}

			// We have not yet processed this location. We can do potentially smarter things here.
			if case .required = fill {
				print("TextMetrics: taking a shortcut that could be slow")
			}

			let target = storage.currentLength

			return (target, fill)
		case let .entireDocument(fill: fill):
			return (storage.currentLength, fill)
		case .processed:
			return (rangeProcessor.maximumProcessedLocation ?? 0, .none)
		}
	}

	public func lines(for range: NSRange) -> [Line<Int>] {
		ensureProcessed(range.max)

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

	public var invalidationHandler: RangeInvalidationBuffer.Handler {
		get { invalidator.invalidationHandler }
		set {
			invalidator.invalidationHandler = { [rangeProcessor] in
				let target = $0.apply(mutations: rangeProcessor.pendingMutations)
				
				newValue(target)
			}
		}
	}
}

extension TextMetrics {
	public var textStorageMonitor: TextStorageMonitor {
		rangeProcessor
			.textStorageMonitor
			.withInvalidationBuffer(invalidator)
	}

	/// Apply an effective change.
	///
	/// This is invoked lazily by `rangeProcessor`.
	private func didChange(_ mutation: RangeMutation, completion: @escaping () -> Void) {
		let limit = mutation.postApplyLimit
		let range = mutation.range
		let delta = mutation.delta

		let lowerIndex = lastLineIndex(before: range.location)
		let upperIndex = firstLineIndex(after: range.max)

		let lowerReadLocation = lowerIndex.flatMap { line(at: $0)?.lowerBound } ?? 0
		let upperReadLocation = upperIndex.flatMap { line(at: $0)?.lowerBound }.map { min($0 + delta, limit) } ?? limit

		let affectedRange = NSRange(lowerReadLocation..<upperReadLocation)

		guard let substring = try? storage.substring(with: affectedRange) else {
			fatalError("Unable to compute substring from readableRange")
		}

		let replacementLower = lowerIndex ?? lineList.startIndex
		let replacementUpper: Int

		if affectedRange.max < limit {
			replacementUpper = upperIndex ?? lineList.endIndex
		} else {
			replacementUpper = lineList.endIndex
		}

		let indexOffset = lowerIndex ?? 0
		let includeLastLine = affectedRange.max == limit

		// this is currently always async, but it could potentially be conditional on the size of edit
		Task {
			let replacementRange = replacementLower..<replacementUpper
			async let weightedValues = parseLines(
				in: substring,
				indexOffset: indexOffset,
				locationOffset: affectedRange.location,
				includeLastLine: includeLastLine
			)
			
			self.lineList.replaceSubrange(replacementRange, with: await weightedValues)
			completion()
			
			publishAffectedRange(affectedRange)
		}
	}
	
	nonisolated func parseLines(in substring: String, indexOffset: Int, locationOffset: Int, includeLastLine: Bool) -> [TextMetrics.List.WeightedValue] {
		let newLines = parser.parseLines(
			in: substring,
			indexOffset: indexOffset,
			locationOffset: locationOffset,
			includeLastLine: includeLastLine
		)
		
		return newLines.map { $0.weightedValue }
	}
	
	private func publishAffectedRange(_ range: NSRange) {
		let effectiveRange: NSRange
		
		if range.length > 0 {
			effectiveRange = range
		} else {
			// we cannot invalidate an empty range, so we have to make it non-empty. We can try two possible expansions. But if neither work, there's nothing we can do.
			let expandedRange = range.shifted(startBy: -1) ?? range.shifted(startBy: 1)
			
			guard let expandedRange else {
				print("Failed to expand \(range)")
				return
			}
			
			effectiveRange = expandedRange
		}
		
		self.invalidator.invalidate(.range(effectiveRange))
	}
}

extension TextMetrics {
	private func firstLineIndex(after location: Int) -> Int? {
		lineList.binarySearch { record, _ in
			location < record.dependency
		}
	}

	private func lastLineIndex(before location: Int) -> Int? {
		let descIdx = lineList.reversed().firstIndex { record in
			record.dependency <= location
		}

		guard let descIdx else { return nil }

		// have to adjust the index around here because we used reversed()
		return lineList.index(before: descIdx.base)
	}
}

extension TextMetrics {
	public func lineSpan(for range: NSRange, mode: RangeFillMode = .none) -> (Line<Int>, Line<Int>)? {
		let max = range.upperBound
		let min = range.lowerBound

		guard rangeProcessor.processLocation(max, mode: mode) else {
			return nil
		}

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
