import AppKit
import Foundation

import ChimeKit

public struct DocumentContent {
	public let storage: NSTextStorage
	public let identity: DocumentContentIdentity

	init(storage: NSTextStorage) {
		self.storage = storage
		self.identity = DocumentContentIdentity()
	}

	/// Initialize with default, empty storage
	public init() {
		self.init(storage: NSTextStorage())
	}

	/// Initialize by reading data in a file.
	public init(url: URL, documentAttributes: [NSAttributedString.Key : Any]) throws {
		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.defaultAttributes: documentAttributes,
		]

		let storage = try NSTextStorage(url: url, options: options, documentAttributes: nil)

		self.init(storage: storage)
	}
}

extension DocumentContent: Equatable {
	public static func == (lhs: DocumentContent, rhs: DocumentContent) -> Bool {
		return lhs.storage === rhs.storage && lhs.identity == rhs.identity
	}
}
