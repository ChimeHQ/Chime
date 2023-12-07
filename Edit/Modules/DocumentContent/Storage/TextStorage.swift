import Foundation

public struct TextStorage {
	// mutation
	public let beginEditing: () -> Void
	public let endEditing: () -> Void
	public let applyMutation: ([TextStorageMutation]) -> Void

	// read-only
	public let length: () -> Int
	public let substring: (NSRange) throws -> String

	public init(
		beginEditing: @escaping () -> Void,
		endEditing: @escaping () -> Void,
		applyMutation: @escaping ([TextStorageMutation]) -> Void,
		length: @escaping () -> Int,
		substring: @escaping (NSRange) throws -> String
	) {
		self.beginEditing = beginEditing
		self.endEditing = endEditing
		self.applyMutation = applyMutation
		self.length = length
		self.substring = substring
	}
}

public final class TextStorageReference {
	var storage: TextStorage

	public init(storage: TextStorage) {
		self.storage = storage
	}

	public var length: Int {
		storage.length()
	}

	public func substring(from range: NSRange) throws -> String {
		try storage.substring(range)
	}
}
