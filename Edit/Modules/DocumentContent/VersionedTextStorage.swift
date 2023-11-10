import AppKit

import TextStory

public final class VersionedTextStorage: TSYTextStorage {
	/// A number that is incremented every time the text content changes.
	public private(set) var version: Int = 0

	public override func edited(_ editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		super.edited(editedMask, range: editedRange, changeInLength: delta)

		if editedMask.contains(.editedCharacters) {
			self.version += 1
		}
	}
}
