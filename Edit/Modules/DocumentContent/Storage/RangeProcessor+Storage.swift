import Foundation

import RangeState

extension RangeProcessor {
	func didApplyMutation(_ mutation: TextStorageMutation) {
		didChangeContent(in: mutation.range, delta: mutation.delta)
	}

	var textStorageMonitor: TextStorageMonitor {
		.init(
			willApplyMutation: { _ in },
			didApplyMutation: didApplyMutation
		)
	}
}

extension TextStorageMonitor {
	public func withInvalidationBuffer(_ invalidator: RangeInvalidationBuffer) -> TextStorageMonitor {
		.init(
			willApplyMutation: {
				invalidator.beginBuffering()

				self.willApplyMutation($0)
			},
			didApplyMutation: {
				self.didApplyMutation($0)

				invalidator.endBuffering()
			}
		)
	}
}
