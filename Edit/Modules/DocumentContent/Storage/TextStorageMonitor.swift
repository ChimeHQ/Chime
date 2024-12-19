import Foundation

public struct TextStorageMonitor {
	public typealias Handler = (TextStorageMutation) -> Void

	public let willApplyMutation: Handler
	public let didApplyMutation: Handler

	public init(
		willApplyMutation: @escaping Handler,
		didApplyMutation: @escaping Handler
	) {
		self.willApplyMutation = willApplyMutation
		self.didApplyMutation = didApplyMutation
	}
}

extension TextStorageMonitor {
	@MainActor
	public static let null = TextStorageMonitor(willApplyMutation: { _ in }, didApplyMutation: { _ in })

	public init(monitors: [TextStorageMonitor]) {
		self.init(
			willApplyMutation: {
				for monitor in monitors {
					monitor.willApplyMutation($0)
				}
			},
			didApplyMutation: {
				for monitor in monitors {
					monitor.didApplyMutation($0)
				}
			}
		)
	}

	public init(monitorProvider: @escaping () -> TextStorageMonitor) {
		self.init(
			willApplyMutation: {
				monitorProvider().willApplyMutation($0)
			},
			didApplyMutation: {
				monitorProvider().didApplyMutation($0)
			}
		)
	}
}
