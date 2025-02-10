import Foundation

public struct TextStorageMonitor {
	public typealias Handler = (TextStorageMutation) -> Void

	public let willBeginEditing: () -> Void
	public let didEndEditing: () -> Void
	public let willApplyMutation: Handler
	public let didApplyMutation: Handler

	public init(
		willBeginEditing: @escaping () -> Void = {},
		didEndEditing: @escaping () -> Void = {},
		willApplyMutation: @escaping Handler,
		didApplyMutation: @escaping Handler
	) {
		self.willApplyMutation = willApplyMutation
		self.didApplyMutation = didApplyMutation
		
		self.willBeginEditing = willBeginEditing
		self.didEndEditing = didEndEditing
	}
}

extension TextStorageMonitor {
	@MainActor
	public static let null = TextStorageMonitor(willApplyMutation: { _ in }, didApplyMutation: { _ in })

	public init(monitors: [TextStorageMonitor]) {
		self.init(
			willBeginEditing: {
				for monitor in monitors {
					monitor.willBeginEditing()
				}
			},
			didEndEditing: {
				for monitor in monitors {
					monitor.didEndEditing()
				}
			},
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
			willBeginEditing: {
				monitorProvider().willBeginEditing()
			},
			didEndEditing: {
				monitorProvider().didEndEditing()
			},
			willApplyMutation: {
				monitorProvider().willApplyMutation($0)
			},
			didApplyMutation: {
				monitorProvider().didApplyMutation($0)
			}
		)
	}
}
