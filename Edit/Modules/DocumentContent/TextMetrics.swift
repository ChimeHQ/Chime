import Foundation

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

extension Line {
	init(record: TextMetrics.List.Record, index: Int) {
		self.init(
			index: index,
			range: NSRange(location: record.dependency, length: record.weight),
			whitespaceOnly: record.value.whitespaceOnly
		)
	}

	var weightedValue: TextMetrics.List.WeightedValue {
		.init(
			value: TextMetrics.LineValue(whitespaceOnly: whitespaceOnly),
			weight: range.length
		)
	}
}

@MainActor
public final class TextMetrics {
	public typealias ValueProvider = HybridSyncAsyncValueProvider<Query, TextMetrics, Never>

	public nonisolated static let invalidationSetKey = "set"
	public nonisolated static let textMetricsDidChangeNotification = Notification.Name("textMetricsDidChangeNotification")

	public typealias Version = Int
	typealias List = RelativeArray<LineValue, Int>
//	typealias List = RelativeList<LineValue, Int>
	public typealias Storage = TextStorage<Version>
	typealias Processor = RangeProcessor

	struct LineValue {
		let whitespaceOnly: Bool
	}

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
			changeHandler: { self.didChange($0, completion: $1) }
		)
	)

	private let parser = LineParser()
//	private let lineList = List()
	private var lineList = List()
	let storage: Storage
	private var thing: Int = 0

	public init(storage: Storage) {
		self.storage = storage

		// insert a single empty line as a starting point
		let line = Line(index: 0, range: NSRange(0..<0), whitespaceOnly: true)

		lineList.append(line.weightedValue)
//		lineList.insert(line.weightedValue, at: 0)
	}

	private func ensureProcessed(_ location: Int) {
		rangeProcessor.processLocation(location, mode: .required)
	}

	public var valueProvider: ValueProvider {
		.init(
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
			if let location = line(at: index)?.max {
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

	public func lines(for range: NSRange) -> [Line] {
		ensureProcessed(range.max)

		let lowerIndex = lastLineIndex(before: range.location) ?? lineList.startIndex
		let passIndex = firstLineIndex(after: range.max) ?? lineList.endIndex

		// that upper is *past* the range, so we need to back up one
		let upperIndex = lineList.index(before: passIndex)

		return lineList[lowerIndex..<upperIndex].enumerated().map { index, record in
			Line(record: record, index: index + lowerIndex)
		}
	}

	public func line(for location: Int) -> Line? {
		guard let idx = lastLineIndex(before: location) else { return nil }

		return Line(record: lineList[idx], index: idx)
	}

	public func line(at index: Int) -> Line? {
		lineList[safe: index].map { Line(record: $0, index: index) }
	}

	public var lastLine: Line {
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
	private func didChange(_ mutation: RangeMutation, completion: @escaping @MainActor () -> Void) {
		let limit = mutation.postApplyLimit
		let range = mutation.range
		let delta = mutation.delta

		let lowerIndex = lastLineIndex(before: range.location)
		let upperIndex = firstLineIndex(after: range.max)

		let lowerReadLocation = lowerIndex.flatMap { line(at: $0)?.range.location } ?? 0
		let upperReadLocation = upperIndex.flatMap { line(at: $0)?.range.location }.map { min($0 + delta, limit) } ?? limit

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

		DispatchQueue.global().asyncUnsafe {
			let newLines = self.parser.parseLines(in: substring, indexOffset: indexOffset, locationOffset: affectedRange.location, includeLastLine: includeLastLine)

			let replacementRange = replacementLower..<replacementUpper

			let weightedValues = newLines.map { $0.weightedValue }

			DispatchQueue.main.async {
				self.lineList.replaceSubrange(replacementRange, with: weightedValues)

				completion()
				self.invalidator.invalidate(.range(affectedRange))
			}
		}
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
	public func lineSpan(for range: NSRange, mode: RangeFillMode = .none) -> (Line, Line)? {
		let max = range.upperBound
		let min = range.lowerBound

		guard rangeProcessor.processLocation(max, mode: mode) else {
			return nil
		}

		guard let start = line(for: min) else {
			return nil
		}

		// just skip a lookup if we can
		if start.range.contains(max) {
			return (start, start)
		}

		guard let end = line(for: max) else {
			return nil
		}

		return (start, end)
	}
}
