import Foundation

import Neon

extension RangeProcessor {
	func didApplyMutations(_ mutations: [TextStorageMutation]) {
		let stringMutations = mutations.flatMap({ $0.stringMutations })

		for mutation in stringMutations {
			contentChanged(in: mutation.range, delta: mutation.delta)
		}
	}

	var textStorageMonitor: TextStorageMonitor {
		.init(
			willApplyMutations: { _ in },
			didApplyMutations: didApplyMutations,
			didCompleteMutations: { _ in }
		)
	}
}

extension TextStorageMonitor {
	func withInvalidationBuffer(_ invalidator: RangeInvalidationBuffer) -> TextStorageMonitor {
		.init(
			willApplyMutations: {
				invalidator.beginBuffering()

				self.willApplyMutations($0)
			},
			didApplyMutations: didApplyMutations,
			didCompleteMutations: {
				self.didCompleteMutations($0)

				invalidator.endBuffering()
			}
		)
	}
}
