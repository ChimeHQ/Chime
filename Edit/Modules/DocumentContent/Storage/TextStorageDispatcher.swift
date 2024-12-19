import Foundation

public final class TextStorageDispatcher<Version: Sendable> {
	public typealias Storage = TextStorage<Version>

	public let storage: Storage
	public let monitors: [TextStorageMonitor]

	public init(storage: Storage, monitors: [TextStorageMonitor]) {
		self.storage = storage
		self.monitors = monitors
	}

	public func apply(_ mutation: TextStorageMutation) {
		beginEditing(with: mutation)

		storage.applyMutation(mutation)

		endEditing(with: mutation)
	}
}

extension TextStorageDispatcher {
	private func beginEditing(with mutation: TextStorageMutation) {
		for monitor in monitors {
			monitor.willApplyMutation(mutation)
		}

		storage.beginEditing()
	}

	private func endEditing(with mutation: TextStorageMutation) {
		for monitor in monitors {
			monitor.didApplyMutation(mutation)
		}

		storage.endEditing()
	}
}
