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
public final class TextMetricsCalculator {
	public typealias ValueProvider = HybridSyncAsyncValueProvider<Query, TextMetrics, Never>

	public nonisolated static let invalidationSetKey = "set"
	public nonisolated static let textMetricsDidChangeNotification = Notification.Name("textMetricsDidChangeNotification")

	public typealias Version = Int
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
	private var metrics = TextMetrics()
	let storage: Storage

	public init(storage: Storage) {
		self.storage = storage
	}

	private func ensureProcessed(_ location: Int) {
		rangeProcessor.processLocation(location, mode: .required)
	}

//	public var valueProvider: ValueProvider {
//		.init(
//			isolation: MainActor.shared,
//			rangeProcessor: rangeProcessor,
//			inputTransformer: transformQuery,
//			syncValue: { _ in metrics },
//			asyncValue: { _ in metrics },
//		)
//	}

	private func transformQuery(_ query: Query) -> (Int, RangeFillMode) {
		let value: (Int, RangeFillMode)
		let length = storage.currentLength
		
		switch query {
		case let .location(location, fill: fill):
			value = (location, fill)
		case let .index(index, fill: fill):
			// we have seen processed this location
			if let location = metrics.line(at: index)?.upperBound {
				value = (location, fill)
				break
			}

			// We have not yet processed this location. We can do potentially smarter things here.
			if case .required = fill {
				print("TextMetrics: taking a shortcut that could be slow")
			}

			value = (length, fill)
		case let .entireDocument(fill: fill):
			value = (length, fill)
		case .processed:
			value = (rangeProcessor.processedUpperBound - 1, .none)
		}
		
		// we really want to allow queries that equal the length here, because that last position is frequently encountered. But the RangeProcessor isn't expecting that, so we have to clamp
		let clampedLocation = max(min(length - 1, value.0), 0)
		
		return (clampedLocation, value.1)
	}

	public var valueProvider: ValueProvider {
		HybridSyncAsyncValueProvider(
			isolation: MainActor.shared,
			rangeProcessor: rangeProcessor,
			inputTransformer: transformQuery,
			syncValue: { _ in
				self.metrics
			},
			asyncValue: { _ in
				self.metrics
			}
		)
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

extension TextMetricsCalculator {
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

		let lowerIndex = metrics.lastLineIndex(before: range.location)
		let upperIndex = metrics.firstLineIndex(after: range.max)

		let lowerReadLocation = lowerIndex.flatMap { metrics.line(at: $0)?.lowerBound } ?? 0
		let upperReadLocation = upperIndex.flatMap { metrics.line(at: $0)?.lowerBound }.map { min($0 + delta, limit) } ?? limit

		let affectedRange = NSRange(lowerReadLocation..<upperReadLocation)

		guard let substring = try? storage.substring(with: affectedRange) else {
			fatalError("Unable to compute substring from readableRange")
		}

		let replacementLower = lowerIndex ?? metrics.lineList.startIndex
		let replacementUpper: Int

		if affectedRange.max < limit {
			replacementUpper = upperIndex ?? metrics.lineList.endIndex
		} else {
			replacementUpper = metrics.lineList.endIndex
		}

		let indexOffset = lowerIndex ?? 0
		let includeLastLine = affectedRange.max == limit
		let version = storage.currentVersion
		let length = storage.currentLength
		
		// this is currently always async, but it could potentially be conditional on the size of edit
		Task {
			let replacementRange = replacementLower..<replacementUpper
			async let weightedValues = parseLines(
				in: substring,
				indexOffset: indexOffset,
				locationOffset: affectedRange.location,
				includeLastLine: includeLastLine
			)
			
			self.metrics.lineList.replaceSubrange(replacementRange, with: await weightedValues)
			completion()
			self.metrics.storageLength = length
			self.metrics.storageVersion = version
			
			publishAffectedRange(affectedRange, length: length)
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
	
	private func publishAffectedRange(_ range: NSRange, length: Int) {
		// if the storage length here is zero, we can still push out a reasonable invalidation here, despite it not really being a meaningful range
		if length == 0 {
			self.invalidator.invalidate(.all)
			return
		}
		
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
