import Foundation

public struct TextStorageMonitor {
	public typealias Handler = ([TextStorageMutation]) -> Void

	public let willApplyMutations: Handler
	public let didApplyMutations: Handler
	public let didCompleteMutations: Handler

	public init(
		willApplyMutations: @escaping Handler,
		didApplyMutations: @escaping Handler,
		didCompleteMutations: @escaping Handler
	) {
		self.willApplyMutations = willApplyMutations
		self.didApplyMutations = didApplyMutations
		self.didCompleteMutations = didCompleteMutations
	}
}

extension TextStorageMonitor {
	public static let null = TextStorageMonitor(willApplyMutations: { _ in }, didApplyMutations: { _ in }, didCompleteMutations: { _ in })

	public init(monitors: [TextStorageMonitor]) {
		self.init(
			willApplyMutations: {
				for monitor in monitors {
					monitor.willApplyMutations($0)
				}
			},
			didApplyMutations: {
				for monitor in monitors {
					monitor.didApplyMutations($0)
				}
			},
			didCompleteMutations: {
				for monitor in monitors {
					monitor.didCompleteMutations($0)
				}
			}
		)
	}

	public init(monitorProvider: @escaping () -> TextStorageMonitor) {
		self.init(
			willApplyMutations: {
				monitorProvider().willApplyMutations($0)
			},
			didApplyMutations: {
				monitorProvider().didApplyMutations($0)
			},
			didCompleteMutations: {
				monitorProvider().didCompleteMutations($0)
			}
		)
	}
}
