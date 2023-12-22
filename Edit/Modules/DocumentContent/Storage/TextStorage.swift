import Foundation

public enum TextStorageError: Error {
	case underlyingStorageInvalid
	case rangeInvalid(NSRange, length: Int)
	case stale
}

public struct TextStorage<Version> {
	// mutation
	public let beginEditing: () -> Void
	public let endEditing: () -> Void
	public let applyMutations: ([TextStorageMutation]) -> Void

	// read-only
	public let version: () -> Version
	public let length: (Version) -> Int?
	public let substring: (NSRange, Version) throws -> String

	public init(
		beginEditing: @escaping () -> Void,
		endEditing: @escaping () -> Void,
		applyMutations: @escaping ([TextStorageMutation]) -> Void,
		version: @escaping () -> Version,
		length: @escaping (Version) -> Int?,
		substring: @escaping (NSRange, Version) throws -> String
	) {
		self.beginEditing = beginEditing
		self.endEditing = endEditing
		self.applyMutations = applyMutations
		self.version = version
		self.length = length
		self.substring = substring
	}

	public var currentVersion: Version {
		version()
	}

	public var currentLength: Int {
		guard let value = length(currentVersion) else {
			preconditionFailure("Calculating the length of the current storage version must always be possible")
		}

		return value
	}

	public func substring(with range: NSRange) throws -> String {
		try substring(range, currentVersion)
	}
}

extension TextStorage where Version : AdditiveArithmetic {
	public static func null() -> Self {
		.init(
			beginEditing: { },
			endEditing: {},
			applyMutations: { _ in },
			version: { Version.zero },
			length: { _ in 0},
			substring: { range, _ in
				throw TextStorageError.rangeInvalid(range, length: 0)
			}
		)
	}
}
