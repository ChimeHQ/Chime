import AppKit
import Foundation

import ChimeKit
import TextStory

public struct DocumentContent {
	private var contentID = UUID()

	public let storage: TextStorageReference

	/// Access structural information about the text.
	///
	/// This reference will remain stable across the lifetime of a editor window, even if the content is changed.
	public let metrics: DocumentMetrics

	/// Initialize with default, empty storage
	public init(storage: TextStorage) {
		let storageRef = TextStorageReference(storage: storage)

		self.storage = storageRef
		self.metrics = DocumentMetrics(storage: storageRef)
	}

	public mutating func replaceStorage(_ newStorage: TextStorage) {
		self.storage.storage = newStorage

		//metrics.resetSomehow()

		self.contentID = UUID()
	}
}

extension DocumentContent: Equatable {
	public static func == (lhs: DocumentContent, rhs: DocumentContent) -> Bool {
		lhs.contentID == rhs.contentID
	}
}

extension DocumentContent {
	public static let textStorageMutationsKey = "mutations"
	public static let willApplyMutationsNotification = Notification.Name("willApplyMutationsNotification")
	/// This is very strongly recommended to restrict events only to the actual document content you are interested in. If it is not used, you will receive events from all open documents.
	public static let didApplyMutationsNotification = Notification.Name("didApplyMutationsNotification")
	public static let didCompleteMutationsNotification = Notification.Name("didCompleteMutationsNotification")

	private func postEvent(_ named: Notification.Name, _ mutations: [TextStorageMutation]) {
		NotificationCenter.default.post(
			name: named,
			object: storage,
			userInfo: [DocumentContent.textStorageMutationsKey: mutations]
		)
	}

	public var notificationMonitor: TextStorageDispatcher.Monitor {
		.init(
			willApplyMutations: { postEvent(Self.willApplyMutationsNotification, $0) },
			didApplyMutations: { postEvent(Self.didApplyMutationsNotification, $0) },
			didCompleteMutations: { postEvent(Self.didCompleteMutationsNotification, $0) }
		)
	}
}
