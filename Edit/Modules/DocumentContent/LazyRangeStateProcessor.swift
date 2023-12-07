import Foundation

import Rearrange

extension RangedString {
	var rangeMutation: RangeMutation {
		RangeMutation(range: range, delta: string.utf16.count)
	}
}

public final class LazyRangeStateProcessor {
	public struct Processor {
		public let willChange: (NSRange, Int) -> Void
		public let didChange: (NSRange, Int) -> Void

		public init(
			willChange: @escaping (NSRange, Int) -> Void = { _, _ in },
			didChange: @escaping (NSRange, Int) -> Void
		) {
			self.willChange = willChange
			self.didChange = didChange
		}
	}

	public struct Configuration {
		public let minimumDelta: Int

		public init(minimumDelta: Int = 1024) {
			self.minimumDelta = minimumDelta
		}
	}

	public let processor: Processor
	public private(set) var maximumProcessedLocation: Int?

	public init(configuration: Configuration = Configuration(), processor: Processor) {
		self.processor = processor
	}

	public func needsToProcessChange(in range: NSRange) -> Bool {
		needsToProcessAccess(at: range.location)
	}

	public func needsToProcessAccess(at location: Int) -> Bool {
		guard let max = maximumProcessedLocation else { return true }

//		return location < max
		return true
	}
}

extension LazyRangeStateProcessor {
	public func contentWillChange(in range: NSRange, delta: Int) {
		guard needsToProcessChange(in: range) else { return }

		processor.willChange(range, delta)
	}

	public func contentDidChange(in range: NSRange, delta: Int) {
		guard needsToProcessChange(in: range) else { return }

		processor.didChange(range, delta)
	}
}

// local extension for convenience
extension LazyRangeStateProcessor {
	public func willApplyMutations(_ mutations: [TextStorageMutation]) {
		for mutation in mutations {
			for stringMutation in mutation.stringMutations {
				contentWillChange(in: stringMutation.range, delta: stringMutation.string.utf16.count)
			}
		}
	}

	public func didApplyMutations(_ mutations: [TextStorageMutation]) {
		for mutation in mutations {
			for stringMutation in mutation.stringMutations {
				contentDidChange(in: stringMutation.range, delta: stringMutation.string.utf16.count)
			}
		}
	}
}

