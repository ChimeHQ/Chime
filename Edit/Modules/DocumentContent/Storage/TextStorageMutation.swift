import Foundation

/// Represents a single logical text change, possibly associated with a cursor.
public struct TextStorageMutation: Hashable, Sendable {
	public let range: NSRange
	public let string: String

	public init(range: NSRange, string: String) {
		self.range = range
		self.string = string
	}

	public init(insert string: String, at position: Int) {
		self.init(range: NSRange(position..<position), string: string)
	}

	public var delta: Int {
		string.utf16.count - range.length
	}
}
