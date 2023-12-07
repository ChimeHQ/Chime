import Foundation

/// A string with an associated range.
public struct RangedString: Hashable, Sendable {
	public let range: NSRange
	public let string: String

	public init(range: NSRange, string: String) {
		self.range = range
		self.string = string
	}

	public init(insert string: String, at location: Int) {
		self.init(range: NSRange(location: location, length: 0), string: string)
	}
}

/// Represents a single cursor within an editor view.
public struct Cursor: Hashable, Sendable {
	public let index: Int

	/// The current selection state of the cursor.
	public let selection: NSRange
}

/// Represents the current cursor state and a possible final selection.
public struct CursorMutation: Hashable, Sendable {
	public let cursor: Cursor

	/// The desired final selection state of the cursor.
	///
	///	If this value is set, it should override any default selection mutation logic that might affect selection during content mutations.
	public let selection: NSRange?
}

/// Represents a single logical text change, possibly associated with a cursor.
public struct TextStorageMutation: Hashable, Sendable {
	public let stringMutations: [RangedString]

	/// The cursor state and mutation to apply, if any.
	///
	/// When this value is nil, the text mutations should attempt to preserve selection state of the cursors as much as possible.
	public let cursorMutation: CursorMutation?

	public init(stringMutations: [RangedString], cursorMutation: CursorMutation? = nil) {
		self.stringMutations = stringMutations
		self.cursorMutation = cursorMutation
	}

	public init(stringMutation: RangedString, cursorMutation: CursorMutation? = nil) {
		self.stringMutations = [stringMutation]
		self.cursorMutation = cursorMutation
	}

	public init(insert string: String, at location: Int) {
		self.init(stringMutation: .init(insert: string, at: location))
	}
}
