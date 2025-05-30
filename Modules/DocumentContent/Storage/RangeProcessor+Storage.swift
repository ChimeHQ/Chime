import Foundation

import RangeState

extension RangeProcessor {
	@MainActor
	func didApplyMutation(_ mutation: TextStorageMutation) {
		didChangeContent(in: mutation.range, delta: mutation.delta)
	}

	@MainActor
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
			willBeginEditing: {
				invalidator.beginBuffering()
				self.willBeginEditing()
			},
			didEndEditing: {
				self.didEndEditing()
				invalidator.endBuffering()
			},
			willApplyMutation: willApplyMutation,
			didApplyMutation: didApplyMutation
		)
	}
}
