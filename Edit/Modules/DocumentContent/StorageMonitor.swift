import AppKit
import OSLog

import TextStory
import Utility

public final class StorageMonitor: NSObject {
	private let logger = Logger(type: StorageMonitor.self)

	public func monitor(_ content: DocumentContent) {
		content.storage.storageDelegate = self
	}
}

extension StorageMonitor: TSYTextStorageDelegate {
	public func textStorage(_ textStorage: TSYTextStorage, willReplaceCharactersIn range: NSRange, with string: String) {
		logger.info("thing A")
	}

	public func textStorage(_ textStorage: TSYTextStorage, didReplaceCharactersIn range: NSRange, with string: String) {
	}

	public func textStorageWillCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
	}

	public func textStorageDidCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
	}

	public func textStorage(_ textStorage: TSYTextStorage, doubleClickRangeForLocation location: UInt) -> NSRange {
		return NSRange(location: Int(location), length: 1)
	}

	public func textStorage(_ textStorage: TSYTextStorage, nextWordIndexFromLocation location: UInt, direction forward: Bool) -> UInt {
		return location
	}
}
