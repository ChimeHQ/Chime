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
	public let applyMutation: (TextStorageMutation) -> Void

	// read-only
	public let version: () -> Version
	public let length: (Version) -> Int?
	public let substring: (NSRange, Version) throws -> String

	public init(
		beginEditing: @escaping () -> Void,
		endEditing: @escaping () -> Void,
		applyMutation: @escaping (TextStorageMutation) -> Void,
		version: @escaping () -> Version,
		length: @escaping (Version) -> Int?,
		substring: @escaping (NSRange, Version) throws -> String
	) {
		self.beginEditing = beginEditing
		self.endEditing = endEditing
		self.applyMutation = applyMutation
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

	public var string: String {
		guard let value = try? substring(with: NSRange(0..<currentLength)) else {
			preconditionFailure("Failed to get a substring with the current length")
		}

		return value
	}
}

extension TextStorage where Version : AdditiveArithmetic {
	public static func null() -> Self {
		.init(
			beginEditing: { },
			endEditing: {},
			applyMutation: { _ in },
			version: { Version.zero },
			length: { _ in 0},
			substring: { range, _ in
				throw TextStorageError.rangeInvalid(range, length: 0)
			}
		)
	}

	public func relaying(to monitors: [TextStorageMonitor]) -> Self {
		.init(
			beginEditing: beginEditing,
			endEditing: endEditing,
			applyMutation: {
				for monitor in monitors {
					monitor.willApplyMutation($0)
				}

				self.applyMutation($0)

				for monitor in monitors {
					monitor.didApplyMutation($0)
				}
			},
			version: version,
			length: length,
			substring: substring
		)
	}
}
