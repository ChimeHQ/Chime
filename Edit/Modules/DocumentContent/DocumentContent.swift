import AppKit
import Foundation

import ChimeKit
import TextStory

@MainActor
public struct DocumentContent {
	public typealias Version = Int

	public let notificationObject: AnyObject = NSObject()

	public let storage: TextStorage<Version>

	/// Access structural information about the text.
	public let metrics: TextMetrics

	/// Initialize with default, empty storage
	public init(storage: TextStorage<Version>) {
		self.storage = storage
		self.metrics = TextMetrics(storage: storage)
	}
}

extension DocumentContent {
	public static func == (lhs: DocumentContent, rhs: DocumentContent) -> Bool {
		lhs.storage.version() == rhs.storage.version() && lhs.metrics.lineCount == rhs.metrics.lineCount
	}
}
